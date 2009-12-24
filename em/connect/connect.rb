require 'logger'
#
require 'rubygems'
require 'eventmachine'
#
# This example is pretty much striaght from the eventmachine documentation.
# Connects were made to both:
#
# * stompserver on port 51613
# * AMQ on port 61613
#
# The topic/queue name was changed so that AMQ connect matches what it supports.
#
module StompClient
  include EM::Protocols::Stomp
  #
  def initialize *args
    super
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
  end
  #
  def post_init
    @log.debug("post_init done")
  end
  #
  def connection_completed
    connect :login => 'guest', :passcode => 'guest'
    @log.debug("connection_completed done")
  end
  #
  def subscribe(dest,ack=false)
    super(dest,ack)
    @log.debug("subscribe done")
  end
  #
  def receive_msg(msg)
    if msg.command == "CONNECTED"
      @log.debug("received CONNECTED")
      subscribe '/temp-queue/abcd123'
    else
      p ['got a message', msg]
      @log.debug(msg.body)
    end
  end
end
#
EM.run {
  puts "EM.run starts"
  # stompserver
  EM.connect('localhost', 51613, StompClient)
  # AMQ
  # EM.connect('localhost', 61613, StompClient)
  puts "EM.run done"
}

