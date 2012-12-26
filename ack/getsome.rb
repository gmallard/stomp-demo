require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative '../lib/runparms'
  require_relative '../lib/stomphelper'
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "lib")
  require 'runparms'
  require 'stomphelper'
end

#
puts "start"
params = {}
runparms = Runparms.new(params)
use_port = runparms.port
use_port = ENV['STOMP_PORT'].to_i if ENV['STOMP_PORT']
puts runparms.userid
puts runparms.password
puts runparms.host
puts use_port
#
conn = Stomp::Connection.open(runparms.userid, runparms.password, 
  runparms.host, use_port)
#
sub_headers = { 'ack' => 'client' }
conn.subscribe "/queue/ackqt01", sub_headers
#
while true
  msg = conn.receive
  puts "Received: #{msg.body}"
  case msg.body
    when "msg01"
      puts "got 01"
			# Behavior: will vary depending on server implementation.
      # YMMV.
			#----------------------------------------------------
      conn.ack(msg.headers["message-id"])
    when "msg02"
      puts "got 02"
      conn.ack(msg.headers["message-id"])
    when "msg03"
      puts "got 03"
      conn.ack(msg.headers["message-id"])
      break
    else
      raise "Boom - Invalid message: #{msg.body}"
  end
  break if msg.body == "msg03"
end
#
conn.disconnect()
puts "done"

