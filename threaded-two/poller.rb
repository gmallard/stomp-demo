#!/usr/bin/ruby
#
# = Poller
#
# Demonstrate polling for messages.
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
runparms = Runparms.new
conn = Stomp::Connection.open(runparms.userid, runparms.password,
  runparms.host, runparms.port, true)
#
log.debug("Starting thread to poll the socket: #{Thread.current}")
#
rc = 0
Thread.new(conn) do |amq|
    log.debug "Poller: #{Thread.current}"
     while true
        msg = amq.poll
        if msg
          # Process message
          dest = msg.headers["destination"]
          time = Time.now.strftime('%H:%M:%S')
          log.debug "#{time}:#{dest} > #{msg.body.chomp}"
          rc += 1
        else
	        log.debug "sleeping .... #{Thread.current}"
          sleep 0.1
        end
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

