require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'

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
num_msgs = 1
#
puts "Connecting ..."
$stdout.flush
conn = Stomp::Connection.open(login_hash)
#
# Do NOT use too large files here.
# Most servers have some built-in limit on message sizes.
# Sending a 4GB movie probably will not work.
#
f = open(ARGV[0], "r")
message = f.read
f.close
puts "Message size: #{message.size}"
$stdout.flush
#
puts "Publishing ..."
$stdout.flush
1.upto(num_msgs) do |nr|
  puts "Message number: #{nr}"
  $stdout.flush
  conn.publish queue_name, message, headers
end
#
conn.publish queue_name, "QUIT", headers
#
puts "Starting wait ..."
$stdout.flush
sleep 3
#
puts "Disconnecting ..."
$stdout.flush
conn.disconnect()

