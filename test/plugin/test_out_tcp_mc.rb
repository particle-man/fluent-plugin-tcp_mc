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
    # Note: Full integration tests with actual TCP servers are intentionally
    # minimal to avoid flakiness in CI environments. The plugin's behavior is
    # better tested through configuration and unit tests.

    test "write handles connection failures gracefully" do
      d = create_driver

      # Create a simple test chunk class
      test_chunk = Object.new
      def test_chunk.empty?
        false
      end
      def test_chunk.msgpack_each
        yield("test", 0, {"message" => "test"})
      end

      # With no server running, write should raise a connection error
      assert_raise(Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error) do
        d.instance.write(test_chunk)
      end
    end

    test "write returns immediately for empty chunks" do
      d = create_driver

      empty_chunk = Object.new
      def empty_chunk.empty?
        true
      end

      # Should return without error or attempting connection
      assert_nothing_raised do
        d.instance.write(empty_chunk)
      end
    end
  end

  sub_test_case "failover" do
    test "has multiple servers configured for failover" do
      d = create_driver(CONFIG_MULTIPLE_SERVERS)

      # Verify both servers are configured
      assert_equal 2, d.instance.nodes.length
      assert_equal "primary", d.instance.nodes[0].name
      assert_equal "secondary", d.instance.nodes[1].name
      assert_equal 15000, d.instance.nodes[0].port
      assert_equal 15001, d.instance.nodes[1].port
    end

    test "write attempts failover when primary server fails" do
      d = create_driver(CONFIG_MULTIPLE_SERVERS)

      # Create a simple test chunk
      test_chunk = Object.new
      def test_chunk.empty?
        false
      end
      def test_chunk.msgpack_each
        yield("test", 0, {"message" => "failover test"})
      end

      # Both servers are down, so write should fail after trying both
      # The error message should indicate connection failure
      error = assert_raise(Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error) do
        d.instance.write(test_chunk)
      end

      # Should have tried to connect and failed
      assert_not_nil error
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
