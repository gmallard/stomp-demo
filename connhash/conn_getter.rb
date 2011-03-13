require 'rubygems'
require 'stomp'
# require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
#
login_hash = {
	:hosts => [ {:login => "login", :passcode => "passcode", 
							:host => "localhost", :port => 51613}
	],
}
#  :parse_timeout => 30
#
headers = { "ack" => "auto" , "client-id" => "hash_getter" }
queue_name = "/queue/hashliq01"
#
puts "Connecting ..."
conn = Stomp::Connection.open(login_hash)
#
puts "Subscribe ..."
conn.subscribe queue_name, headers
#
puts "Receiving ......"
message = conn.receive
puts "Message: #{message}"
p [ message.body ]

#
# puts "Receiving Second ......"
# message2 = conn.receive
# puts "Message: #{message2}"

puts "Unsubscribing ...."
conn.unsubscribe queue_name
puts "Unsubscribe complete ...."
sleep 30

puts "Disconnecting ..."
conn.disconnect()

