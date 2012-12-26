require 'rubygems'
require 'stomp'

#
login_hash = {
	:hosts => [ {:login => "login", :passcode => "passcode", 
							:host => "localhost", :port => 51613}
	],
      :initial_reconnect_delay => 0.01,
      :max_reconnect_delay => 30.0,
      :use_exponential_back_off => true,
      :back_off_multiplier => 2,
      :max_reconnect_attempts => 10,
      :randomize => false,
      :backup => false,
      :timeout => -1,
      :connect_headers => {},
      :parse_timeout => 5,
      :logger => nil,
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
puts "Starting sleep"
sleep 2
puts "Receiving Second ......"
message2 = conn.receive
puts "Message: #{message2}"

puts "Starting sleep"
sleep 2
puts "Receiving 3rd ......"
message3 = conn.receive
puts "Message: #{message3}"

puts "Unsubscribing ...."
conn.unsubscribe queue_name
puts "Unsubscribe complete ...."
puts "Starting sleep"
sleep 2

puts "Disconnecting ..."
conn.disconnect()

