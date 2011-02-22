require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
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
			# Behavior:
			# a) stompserver_ng: will 'hang', i.e. 'msg02' is never sent untl
			# an 'ack' is received for 'msg01'
			# b) ActiveMQ: Sends all three messages.  I can see the inbound 
			# single ACK in the AMQ logs.However the AMQ Web Console indicates:
			# - 2 messages dequeued
			# - 1 message pending (number 3)
			# c) stompserver (ruby 0.9.9): behaves like stompserver_ng if no ack is
			# sent, but raises an exception if acks are sent :-).
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

