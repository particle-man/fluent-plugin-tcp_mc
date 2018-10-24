#
# Copyright 2017- David Pippenger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/output'
require 'time'
require 'yajl'

module Fluent
  class Tcp_mcOutput < BufferedOutput
    Plugin.register_output('tcp_mc', self)
    
    helpers :compat_parameters, :formatter, :inject

    def initialize
      super
      require 'socket'
      require 'timeout'
      require 'fileutils'
      @nodes = []  #=> [Node]
    end

    config_param :send_timeout, :time, :default => 60
    config_param :connect_timeout, :time, :default => 5
    config_param :include_time_key, :bool, :default => true
    attr_reader :nodes

    def configure(conf)
      super

      compat_parameters_convert(conf, :buffer, :formatter, :inject)

      conf.elements.each do |e|
        next if e.name != "server"

        host = e['host']
        port = e['port']
        port = port ? port.to_i : DEFAULT_LISTEN_PORT

        name = e['name']
        unless name
          name = "#{host}:#{port}"
        end

        @formatter = formatter_create

        @nodes << RawNode.new(name, host, port)
        log.info "adding forwarding server '#{name}'", :host=>host, :port=>port
      end
    end

    def multi_workers_ready?
      true
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
       r = inject_values_to_record(tag, time, record)
      [tag, time, r].to_msgpack
    end

    def write(chunk)
      return if chunk.empty?

      error = nil

      @nodes.each do |node|
        begin
          send_data(node, chunk)
          return
        rescue
          error = $!
        end
      end

      raise error if error
      raise "No nodes available"
    end

    private
    def send_data(node, chunk)
      sock = connect(node)
      begin
        opt = [1, @send_timeout.to_i].pack('I!I!')  # { int l_onoff; int l_linger; }
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, opt)

        opt = [@send_timeout.to_i, 0].pack('L!L!')  # struct timeval
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, opt)

        chunk.msgpack_each do |tag, time, record|
          next unless record.is_a? Hash
          #log.debug ("#{record}")
          sock.write("#{Yajl.dump(record)}\n")
        end
      ensure
        sock.close
      end
    end

    def connect(node)
      Timeout.timeout(@connect_timeout) do
        return TCPSocket.new(node.resolved_host, node.port)
      end
    end

    class RawNode
      attr_reader :name, :host, :port

      def initialize(name, host, port)
        @name = name
        @host = host
        @port = port
        resolved_host
      end

      def resolved_host
        @sockaddr = Socket.pack_sockaddr_in(@port, @host)
        _, rhost = Socket.unpack_sockaddr_in(@sockaddr)
        rhost
      end
    end
  end
end
