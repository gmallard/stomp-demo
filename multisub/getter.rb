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
#
idlist = [ "dummy", "smt01", "smt02"] # size matches num_queues
idcounts = [ -1, 0, 0]
tot_count = 0
num_queues = 2
max_msgs_per_queue = 5
#
1.upto(idlist.size-1) do |q|
	qn = queue_name + "-" + q.to_s
	sn = idlist[q]
	# note that the subscribes are all handled on the same thread,
	# and therefore single threaded
  cli.subscribe(qn, { 'id' => sn } ) {|m|
		p [ Thread.current ]
    message = m
		raise "huh?" if m.headers["subscription"] != sn
		idcounts[q] += 1
		tot_count += 1
  }
end
#
puts "Starting wait ...."
sleep 1 until tot_count == num_queues * max_msgs_per_queue
puts "Ending wait ...."
#
cli.close
#
1.upto(idlist.size-1) do |n|
	puts "#{idlist[n]} : #{idcounts[n]}"
end
#
puts "done"


