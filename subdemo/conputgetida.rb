require 'rubygems'
require 'stomp'
#
puts "starting"
# port = 61613  # AMQ
port = 62613  # Apollo
# port = 51613    # Forked stompserver
qname = "/queue/subtestq1"
the_message = "abcd1234"
#
# =begin
conn = Stomp::Connection.open('loginid', 'password', 'localhost', port)
puts "connection complete: #{conn.inspect}"
conn.subscribe(qname, {:id => 'id-0011'})
puts "subscribe 0011 done"
conn.publish(qname,the_message + " 1")
puts "publish 1 done"
# puts "starting receive 1"
# rec_msg = conn.receive
# puts "recieve 1 done: #{rec_msg.inspect}"
conn.disconnect
# =end
#######################
# =begin
conn = Stomp::Connection.open('loginid', 'password', 'localhost', port)
#
conn.subscribe(qname)
# conn.subscribe(qname, {:id => 'id-0011'})
# puts "subscribe 0011 done"
#
puts "starting receive 2"
rec_msg = conn.receive
puts "recieve 1 done: #{rec_msg.inspect}"
#
conn.disconnect
# =end
#
puts "done"


