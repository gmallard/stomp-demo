require 'socket'
#
connect12 = "CONNECT\n" +
"content-length:0\n" +
"content-type:text/plain; charset=UTF-8\n" +
"login:guest\n" +
"passcode:guest\n" +
"host:localhost\n" +
"accept-version:1.2\n" +
"\n" +
"\x00"
#
send = "SEND\n" +
"content-length:25\n" +
"content-type:text/plain; charset=UTF-8\n" +
"destination:/queue/test.ruby.stomp.test_receipts\n" +
"receipt:1\n" +
"\n" +
"1234567890123456789012345" +
"\x00"
#
subscribe = "SUBSCRIBE\n" +
"content-length:0\n" +
"content-type:text/plain; charset=UTF-8\n" +
"destination:/queue/test.ruby.stomp.test_receipts\n" +
"id:0fc624acf22c22e5ba44bbab9951bf33cf6f4fc0\n" +
"\n" +
"\x00"
#
sock = TCPSocket.new "localhost", 62613 # Apollo
puts "Connect 1"
sock.write(connect12) # CONNECT
# Read CONNECTED
msg = sock.readline("\0") # The CONNECTED frame.  Drop it.
puts "Send 1"
sock.write(send) # SEND
# Read RECEIPT
puts "Read RECEIPT"
msg = sock.readline("\0") # The RECEIPT frame.  Drop it.
puts "Subscribe 1"
sock.write(subscribe) # SUBSCRIBE
puts "Read MESSAGE"
msg = sock.readline("\0") # Should get the MESSAGE frame, but .......
#
puts "Well, well ....."
sock.close
