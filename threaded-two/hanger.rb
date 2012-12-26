#!/usr/bin/ruby
#
# = Hanger
#
# A demonstration program known to 'hang' with various levels of the 
# Ruby stomp client gem.  This code will complete normally with:
#
# * stomp 1.1.1
# * stomp 1.1.5 + fixes
#
# Intermediate releases will hang attempting to run client code like this.
#
require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'
require 'thread'
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative '../lib/runparms'
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "lib")
  require 'runparms'
end

#
log = Logger.new(STDOUT)
log.level = Logger::DEBUG
#
log.debug("Main: #{Thread.current}")
#
runparms = Runparms.new
conn = Stomp::Connection.open(runparms.userid, runparms.password,
  runparms.host, runparms.port, true)
#
log.debug("Connection is: #{conn.inspect}")
log.debug("Starting thread to receive from the socket")
#
rc = 0
Thread.new(conn) do |amq|
    log.debug "Receiver: #{Thread.current}"
    while true
        msg = amq.receive
        log.debug "receive done"
        dest = msg.headers["destination"]
        time = Time.now.strftime('%H:%M:%S')
        log.debug "#{time}:#{dest} > #{msg.body.chomp}"
        rc += 1
    end
end
#
log.debug("Subscribing to /topic/thread.test")
conn.subscribe("/topic/thread.test")
#
log.debug("Sending to /topic/thread.test")
conn.publish("/topic/thread.test", Time.now.to_s)
#
log.debug("Sleeping 1 second")
sleep 1
log.debug("Receive Count: #{rc}")


