require 'rubygems'
require 'stomp'
# require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
#
login_hash = {
	:hosts => [ {:login => "lfgetter", :passcode => "passcode", 
							:host => "localhost", :port => 61613}
	], :parse_timeout => 600
}
#  :parse_timeout => 30
#
headers = { "ack" => "auto" , "client-id" => "hash_getter" }
queue_name = "/queue/lfqueue01"
#
puts "Connecting ..."
conn = Stomp::Connection.open(login_hash)
#
puts "Subscribe ..."
conn.subscribe queue_name, headers
#
puts "Receiving ......"
nr = 0
while true
  nr += 1
  puts "Getting message: #{nr}"
  message = conn.receive
  puts "Size is: #{message.body.size}"
  break if message.body == "QUIT"
end
#
puts "Unsubscribing ...."
conn.unsubscribe queue_name
puts "Unsubscribe complete ...."
#
puts "Disconnecting ..."
conn.disconnect()

