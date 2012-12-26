#!/usr/bin/ruby
#
# = Nosubnorec
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
#
# Demonstrate that 'subscribe' _must_ be called for a connection in order
# to ever receive any messages.
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
# Do not issue 'subscribe' here.
# conn.subscribe "/topic/thread.test"
#
log.debug("Sending to /topic/thread.test")
conn.publish("/topic/thread.test", Time.now.to_s)
log.debug("Sleeping 2 seconds")
#
# Main thread will complete, and the process will end.  A message
# will never be received becuase no 'subscribe' has been issued.
#
sleep 2
log.debug("Receive Count: #{rc}")

