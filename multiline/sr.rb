require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
@log = Logger.new(STDOUT)
@log.level = Logger::DEBUG
# ---------------
def runtest(message, host, port)
  conn = Stomp::Connection.open("login", "password", 
    host, port)
  @log.debug "Connected"

  @log.debug "Length: #{message.size}"
  p [ message ]
  conn.send "/queue/multilend", message
  #
  conn.disconnect
  @log.debug "Disconnected"
  #
  conn = Stomp::Connection.open("login", "password", 
    host, port)
  @log.debug "Connected again"
  #
  conn.subscribe "/queue/multilend", {}
  @log.debug "Subscribe done"
  #
  @log.debug "Starting receive"
  received = conn.receive
  p [ received ]
  p [ received.body ]
  @log.debug "Size: #{received.body.size}"
  @log.debug "Ending receive"
  raise "Boom" unless received.body == message
  raise "Wham" unless received.body.size == message.size
  #
  conn.disconnect
  @log.debug "Disconnected again"
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
runparms = Runparms.new
host = runparms.host
port = runparms.port
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

