require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
#
@log = Logger.new(STDOUT)
@log.level = Logger::DEBUG
@runparms = Runparms.new
@qname = "/queue/test002"
@headers = {}
@reliable = true
#
@log.debug("Main: #{Thread.current}")
#
# Purpose:  provide example code showing differences between two
# stomp broker (server) implementations:
#
# a) stompserver-ng (http://github.com/gmallard/stompserver_ng)
# b) ActiveMQ (http://activemq.apache.org/)
#
# As well as further differences which depend on the implementation
# of client code:
#
# a) Client issues disconnect immediately after send.
# b) Client waits some time after send before disconnect is issued.
#
def example_one(amqsleep = nil)
  #
  # * Running against stompserver_ng:
  #     This method will fail (hang) consistently.
  # * Running against AMQ:
  #     This method will fail (hang) _if_ the sleep time after connect is 'significant'.
  # 
  conn = Stomp::Connection.open(@runparms.userid, @runparms.password,
    @runparms.host, @runparms.port, true)
  #
  @log.debug("Connection is: #{conn.inspect}")
  #
  # -----------------------------------------------------------------------------------
  # Connection 1:
  conn = Stomp::Connection.open("usera", "pwa", @runparms.host, @runparms.port, @reliable)
  # Do issue a subscribe
  conn.subscribe(@qname, @headers)
  # Send a message
  conn.publish(@qname, Time.now.to_s)
  if amqsleep
    sleep amqsleep
  end
  # Do not call 'receive' here, just issue a disconnect.
  conn.disconnect
  # -----------------------------------------------------------------------------------
  # Connection 2:
  conn = Stomp::Connection.open("userb", "pwb", @runparms.host, @runparms.port, @reliable)
  # Subscribe on this connection
  conn.subscribe(@qname, @headers)
  @log.debug "calling receive, which should never complete ......"
  #
  # Running against stompserver_ng, this will never complete.
  # Running against AMQ, this will never complete if the sleep time is significant.
  # Why? Because the message has already been put
  # on the wire by the server.  Connection 1's call to 'subscribe'
  # causes this to occur.
  #
  msg = conn.receive
  @log.debug "Received: #{msg.inspect}"
  conn.disconnect
end
#
# This never completes using stompserver_ng, but does using AMQ.
#
# example_one
#
# This never completes using either server
#
example_one(0.5)

