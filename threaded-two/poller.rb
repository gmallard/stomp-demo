#!/usr/bin/ruby
#
# = Poller
#
# An alternative style for the 'hanger' demonstration.  This
# style should function on all releases of the Ruby stomp client
# gem.
#
require 'rubygems'
require 'stomp'
require 'thread'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
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
Thread.new(conn) do |amq|
    log.debug "Poller: #{Thread.current}"
     while true
        msg = amq.poll
        if msg
          # Process message
          dest = msg.headers["destination"]
          time = Time.now.strftime('%H:%M:%S')
          log.debug "#{time}:#{dest} > #{msg.body.chomp}"
        else
	        log.debug "sleeping .... #{Thread.current}"
          sleep 0.05
        end
    end
end
#
log.debug("Subscribing to /topic/thread.test")
conn.subscribe("/topic/thread.test")
#
log.debug("Sending to /topic/thread.test")
conn.send("/topic/thread.test", Time.now.to_s)
#
log.debug("Sleeping 1 second")
sleep 1

