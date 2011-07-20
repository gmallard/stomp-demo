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
max_sleep = 5
#
idlist = [ "smt01", "smt02", "smt03" ]
idcounts = [ 0, 0, 0 ]
tot_count = 0
max_msgs = 12
#
0.upto(idlist.size-1) do |i|
#  cli.subscribe(queue_name, { :id => idlist[i] } ) {|m|
  cli.subscribe(queue_name, { 'id' => idlist[i] } ) {|m|
    message = m
		mid = message.headers['subscription']
		midx = idlist.index(mid)
    idcounts[midx] += 1
    pname = "proc-#{mid}"
    puts "#{pname} #{Thread.current}"
    puts "#{pname} #{message.body}, count is: #{idcounts[midx]}"
    to_sleep = rand * max_sleep
    puts "#{pname} work time #{to_sleep}"
    sleep to_sleep
    # No need for a lock here, beause all subscribe procs are called
    # in sequential manner from the same thread (Stomp's 'listener
    # thread').
    tot_count += 1
  }
end
#
puts "Starting wait ...."
sleep 1 until tot_count == max_msgs
puts "Ending wait ...."
#
cli.close
#
0.upto(idlist.size-1) do |i|
  puts "For #{idlist[i]} the count is: #{idcounts[i]}"
end
puts "Total count: #{tot_count}"
#
puts "done"


