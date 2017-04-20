require "helper"
require "fluent/plugin/out_tcp_mc.rb"

class Tcp_mcOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::Tcp_mcOutput).configure(conf)
  end
end
