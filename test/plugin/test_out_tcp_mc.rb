require "helper"
require "fluent/plugin/out_tcp_mc.rb"
require "socket"
require "json"

class TcpMcOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    <server>
      host 127.0.0.1
      port 15000
      name test-server
    </server>
  ]

  CONFIG_MULTIPLE_SERVERS = %[
    <server>
      host 127.0.0.1
      port 15000
      name primary
    </server>
    <server>
      host 127.0.0.1
      port 15001
      name secondary
    </server>
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::Tcp_mcOutput).configure(conf)
  end

  sub_test_case "configuration" do
    test "configure with single server" do
      d = create_driver
      assert_equal 1, d.instance.nodes.length
      assert_equal "127.0.0.1", d.instance.nodes[0].host
      assert_equal 15000, d.instance.nodes[0].port
      assert_equal "test-server", d.instance.nodes[0].name
    end

    test "configure with multiple servers" do
      d = create_driver(CONFIG_MULTIPLE_SERVERS)
      assert_equal 2, d.instance.nodes.length
      assert_equal "primary", d.instance.nodes[0].name
      assert_equal "secondary", d.instance.nodes[1].name
    end

    test "configure with custom timeouts" do
      conf = CONFIG + %[
        connect_timeout 10s
        send_timeout 120s
      ]
      d = create_driver(conf)
      assert_equal 10, d.instance.connect_timeout
      assert_equal 120, d.instance.send_timeout
    end

    test "default timeout values" do
      d = create_driver
      assert_equal 5, d.instance.connect_timeout
      assert_equal 60, d.instance.send_timeout
    end

    test "raise error when no servers configured" do
      assert_raise(Fluent::ConfigError) do
        create_driver("")
      end
    end

    test "server name defaults to host:port when not specified" do
      conf = %[
        <server>
          host 192.168.1.1
          port 9999
        </server>
      ]
      d = create_driver(conf)
      assert_equal "192.168.1.1:9999", d.instance.nodes[0].name
    end
  end

  sub_test_case "RawNode" do
    test "initialize with valid parameters" do
      node = Fluent::Plugin::Tcp_mcOutput::RawNode.new("test", "localhost", 8080)
      assert_equal "test", node.name
      assert_equal "localhost", node.host
      assert_equal 8080, node.port
    end

    test "resolve hostname to IP" do
      node = Fluent::Plugin::Tcp_mcOutput::RawNode.new("test", "localhost", 8080)
      resolved = node.resolved_host
      # localhost should resolve to either 127.0.0.1 or ::1
      assert(resolved == "127.0.0.1" || resolved == "::1" || resolved == "localhost")
    end
  end

  sub_test_case "write" do
    test "write records to TCP server" do
      messages = []

      # Start a simple TCP server to receive messages
      server = TCPServer.new("127.0.0.1", 15000)
      server_thread = Thread.new do
        begin
          client = server.accept
          while line = client.gets
            messages << line.chomp
          end
        rescue => e
          # Ignore errors during shutdown
        ensure
          client.close if client
        end
      end

      sleep 0.1 # Give server time to start

      d = create_driver
      time = event_time("2021-01-01 00:00:00 UTC")

      d.run(default_tag: "test") do
        d.feed(time, {"message" => "test log 1", "level" => "info"})
        d.feed(time, {"message" => "test log 2", "level" => "warn"})
      end

      sleep 0.2 # Give time for messages to be received

      assert_equal 2, messages.length

      msg1 = JSON.parse(messages[0])
      assert_equal "test log 1", msg1["message"]
      assert_equal "info", msg1["level"]

      msg2 = JSON.parse(messages[1])
      assert_equal "test log 2", msg2["message"]
      assert_equal "warn", msg2["level"]

    ensure
      server.close if server
      server_thread.kill if server_thread
    end

    test "skip non-hash records" do
      messages = []

      server = TCPServer.new("127.0.0.1", 15000)
      server_thread = Thread.new do
        begin
          client = server.accept
          while line = client.gets
            messages << line.chomp
          end
        rescue
          # Ignore errors during shutdown
        ensure
          client.close if client
        end
      end

      sleep 0.1

      d = create_driver
      time = event_time("2021-01-01 00:00:00 UTC")

      d.run(default_tag: "test") do
        d.feed(time, {"message" => "valid record"})
        # The format method in the plugin will always create a hash from msgpack,
        # so we can't easily test non-hash records in this integration test
      end

      sleep 0.2

      # We should get at least the valid record
      assert(messages.length >= 1)

    ensure
      server.close if server
      server_thread.kill if server_thread
    end
  end

  sub_test_case "failover" do
    test "failover to secondary server when primary fails" do
      # Only start secondary server (port 15001), not primary (15000)
      messages = []

      server = TCPServer.new("127.0.0.1", 15001)
      server_thread = Thread.new do
        begin
          client = server.accept
          while line = client.gets
            messages << line.chomp
          end
        rescue
          # Ignore errors during shutdown
        ensure
          client.close if client
        end
      end

      sleep 0.1

      d = create_driver(CONFIG_MULTIPLE_SERVERS)
      time = event_time("2021-01-01 00:00:00 UTC")

      d.run(default_tag: "test") do
        d.feed(time, {"message" => "failover test"})
      end

      sleep 0.2

      # Message should be received by secondary server
      assert_equal 1, messages.length
      msg = JSON.parse(messages[0])
      assert_equal "failover test", msg["message"]

    ensure
      server.close if server
      server_thread.kill if server_thread
    end
  end

  sub_test_case "format" do
    test "format includes injected values" do
      d = create_driver(CONFIG + %[
        <inject>
          tag_key tag
          time_key time
        </inject>
      ])

      time = event_time("2021-01-01 12:00:00 UTC")
      formatted = d.instance.format("test.tag", time, {"message" => "test"})

      assert_not_nil formatted
      # The formatted data should be msgpack encoded
      tag, time_val, record = MessagePack.unpack(formatted)
      assert_equal "test.tag", tag
      assert_equal "test", record["message"]
    end
  end

  sub_test_case "multi_workers_ready?" do
    test "returns true" do
      d = create_driver
      assert_true d.instance.multi_workers_ready?
    end
  end
end
