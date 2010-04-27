#!/usr/bin/ruby

require 'rubygems'
require 'stomp'
require 'thread'

@conn = Stomp::Connection.open("rip", "foo", "oldpete", 51613, true)


puts("Starting thread to poll the socket")
Thread.new(@conn) do |amq|
    while true
        msg = amq.receive
        dest = msg.headers["destination"]
        time = Time.now.strftime('%H:%M:%S')

        puts "\r#{time}:#{dest} > #{msg.body.chomp}\n"
    end
end

puts("Subscribing to /topic/thread.test")
@conn.subscribe("/topic/thread.test")

puts("Sending to /topic/thread.test")
@conn.send("/topic/thread.test", Time.now.to_s)

puts("Sleeping 1 second")
sleep 1
