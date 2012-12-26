require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative '../lib/runparms'
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "lib")
  require 'runparms'
end

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
# Purpose:  provide example code showing subscribe behavior.
#
def example_one(amqsleep = nil)
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
  # This should hang forever because of the subscribe issued first on 
  # connection 1.
  #
  msg = conn.receive
  @log.debug "Received: #{msg.inspect}"
  conn.disconnect
end
#
example_one(0.5)

