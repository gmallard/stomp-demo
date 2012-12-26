require 'logger'
#
require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'eventmachine'

if Kernel.respond_to?(:require_relative)
  require_relative '../../lib/runparms'
else
  $:.unshift File.join(File.dirname(__FILE__), "../..", "lib")
  require 'runparms'
end

#
# This example is almost like the eventmachine documentation.
#
# Connects were made to both:
#
# * stompserver on port 51613
# * AMQ on port 61613
#
module StompClient
  include EM::Protocols::Stomp
  #
  def initialize(*args)
    super(*args)
    options = (Hash === args.last) ? args.pop : {}
    @conn_headers = {:login => "guest", :passcode => "guestpass"}
    @conn_headers.merge!(options)
    #
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
  end
  #
  def post_init
    @log.debug("post_init done")
  end
  #
  def connection_completed
    connect @conn_headers
    @log.debug("connection_completed done")
  end
  #
  def receive_msg(msg)
    if msg.command == "CONNECTED"
      @log.debug("received CONNECTED : #{msg.inspect}")
    else
      @log.debug("got a message: #{msg.inspect}")
    end
  end
  #
end
#
EM.run {
  puts "EM.run starts"
  #
  runparms = Runparms.new
  port = runparms.port
  host = runparms.host
  #
  conn = EM.connect(host, port, StompClient,
    :login => "gmallard", :passcode => "bigguy")
  puts "EM.run Connection complete to #{host} on port #{port}"
  #
  # Send stomp DISCONNECT frame after 10 seconds.
  #
  EventMachine::add_timer( 10 ) {
    #
    # send_data(data) takes a well-formed stomp frame!
    #
    conn.send_data("DISCONNECT\n\n\x00")
    puts "EM.run disconnect sent"
    #
    EventMachine::stop_event_loop()
  }
  puts "EM.run done"
}

