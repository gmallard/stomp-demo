require 'rubygems'
require 'stomp'

#
login_hash = {
	:hosts => [ {:login => "login", :passcode => "passcode", 
							:host => "localhost", :port => 51613}
	]
}
#
headers = { "ack" => "auto" , "client-id" => "hash_putter",
	:suppress_content_length => false }
queue_name = "/queue/hashliq01"
message = "A\ntesta:xxa\n\na hash style login"
#
puts "Connecting ..."
conn = Stomp::Connection.open(login_hash)
#
puts "Publishing ..."
conn.publish queue_name, message, headers
conn.publish queue_name, message, headers
conn.publish queue_name, message, headers
puts "Disconnecting ..."
conn.disconnect()

