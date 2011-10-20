require 'rubygems'
require 'stomp'
#
puts "starting"
# port = 61613  # AMQ
# port = 62613  # Apollo
port = 51613    # Forked stompserver
conn = Stomp::Connection.open('loginid', 'password', 'localhost', port)
puts "connection complete: #{conn.inspect}"
#
qname = "/queue/subtestq1"
the_message = "abcd1234"
#
# conn.subscribe(qname, {:id => 'id-0099'})
# puts "subscribe 0099 done"
#
conn.publish(qname,the_message + " 1")
puts "publish 1 done"
#
conn.subscribe(qname, {:id => 'id-0099'})
puts "subscribe 0099 done"
#
rec_msg = conn.receive
puts "recieve 1 done: #{rec_msg.inspect}"
#
conn.disconnect
#
puts "done"


