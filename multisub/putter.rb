require 'rubygems' if RUBY_VERSION =~ /1\.8/
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
max_msgs_per_queue = 5
num_queues = 2
#
1.upto(num_queues) do |q|
	1.upto(max_msgs_per_queue) do |i|
		pqn = queue_name + "-" + q.to_s
		omsg = msg_to_send + " #{pqn} / #{i.to_s} / #{max_msgs_per_queue} / "
		cli.publish(pqn, omsg)
		puts omsg
	end
end
#
cli.close
#
puts "done"


