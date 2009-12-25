require 'logger'
#
require 'rubygems'
require 'eventmachine'
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
  def initialize *args
    super
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
    @conn_headers = {:login => "guest", :passcode => "guestpass"}
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
      @log.debug("received CONNECTED")
    else
      @@log.debug("got a message: #{msg.inspect}")
    end
  end
  #
  def set_connection_headers(params = {})
    @conn_headers.merge!(params)
  end
end
#
EM.run {
  puts "EM.run starts"
  #
  port = ENV['STOMP_PORT'] ? ENV['STOMP_PORT'] : 51613
  host = ENV['STOMP_HOST'] ? ENV['STOMP_HOST'] : "localhost"
  #
  conn = EM.connect(host, port, StompClient)
  puts "EM.run Connection complete to #{host} on port #{port}"
  # Override connection parameters.  (Is there another way to do this?)
  conn.set_connection_headers(:login => "gmallard", :passcode => "bigguy" )
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

