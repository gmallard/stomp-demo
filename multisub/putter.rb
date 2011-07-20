require 'rubygems'
require 'stomp'
#
puts "starting"
# port = 61613
# port = 62613
# port = 51613
cli = Stomp::Client.open('loginid', 'password', 'localhost', ARGV[0].to_i)
puts "connection complete"
#
queue_name = "/queue/mtsubtext"
msg_to_send = "The answer is 42. And then some"
max_msgs = 12
#
1.upto(max_msgs) do |i|
  omsg = msg_to_send + " #{i.to_s} / #{max_msgs}"
  cli.publish(queue_name, omsg)
  puts omsg
end
#
cli.close
#
puts "done"


