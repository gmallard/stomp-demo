require 'rubygems'
require 'stomp'
# ---------------
def runtest(message, host, port)
  conn = Stomp::Connection.open("login", "password", 
    host, port)
  puts "Connected"

  puts "Length: #{message.size}"
  p [ message ]
  conn.send "/queue/multilend", message
  #
  conn.disconnect
  puts "Disconnected"
  #
  conn = Stomp::Connection.open("login", "password", 
    host, port)
  puts "Connected again"
  #
  conn.subscribe "/queue/multilend", {}
  puts "Subscribe done"
  #
  puts "Starting receive"
  received = conn.receive
  p [ received ]
  p [ received.body ]
  puts "Size: #{received.body.size}"
  puts "Ending receive"
  raise "Boom" unless received.body == message
  raise "Wham" unless received.body.size == message.size
  #
  conn.disconnect
  puts "Disconnected again"
end

#
messages = [
  "A\n",
  "A\n\n",
  "\nA\n",
  "a\nb\n\nc\n",
  "a\nb\n\nc\n\n",
  "Queue: /queue/testbasic\ndequeued: 0\nsize: 1\nexceptions: 0\nenqueued: 1\n\n",
]
#

host = "localhost"
# host = "oldpete"

port = 51613
# port = 61613
#
for message in messages do
  runtest(message, host, port)
end
#
for message in messages do
  runtest("#{message}\x00\x00\x00", host, port)
end
#
for message in messages do
  runtest("#{message}\x00\x00\x00\n\n\n", host, port)
end
#
for message in messages do
  runtest("#{message}\x00\n\x00\n\x00\n", host, port)
end

