require "helper"
require "fluent/plugin/out_tcp_multi.rb"

class Tcp_multiOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::Tcp_multiOutput).configure(conf)
  end
end
