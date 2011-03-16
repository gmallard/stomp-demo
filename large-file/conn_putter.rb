require 'rubygems'
require 'stomp'
# require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
#
login_hash = {
	:hosts => [ {:login => "lfputter", :passcode => "passcode", 
							:host => "localhost", :port => 61613}
	]
}
#
headers = { "ack" => "auto" , "client-id" => "hash_putter",
	:suppress_content_length => false }
queue_name = "/queue/lfqueue01"
#
f = open(ARGV[0], "r")
message = f.read
f.close
puts "Message size: #{message.size}"
#
num_msgs = 1
#
puts "Connecting ..."
conn = Stomp::Connection.open(login_hash)
#
puts "Publishing ..."
1.upto(num_msgs) do |nr|
  puts "Message number: #{nr}"
  conn.publish queue_name, message, headers
end
#
conn.publish queue_name, "QUIT", headers
#
puts "Starting wait ..."
sleep 30
#
puts "Disconnecting ..."
conn.disconnect()

