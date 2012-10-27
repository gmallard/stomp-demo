require 'socket'

#  CONNECT only uses "\n".  A client library can not know (yet) if this is 
#  really a Stomp 1.2 broker.
connect =  "CONNECT\n" +
    "content-type:text/plain; charset=UTF-8\n" +
    "login:guest\n" +
    "passcode:guest\n" +
    "content-length:0\n" +
    "host:localhost\n" +
    "accept-version:1.2\n" +
    "\n" +
    "\x00"

sessdata_01 = "SEND\r\n" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "destination:/queue/test.ruby.stomp.test_nack11p_0010\r\n" +
    "content-length:40\r\n" +
    "\r\n" +
    "1234567890123456789012345678901234567890" +
    "\x00" +
    "SUBSCRIBE\r\n" +
    "\x00" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "destination:/queue/test.ruby.stomp.test_nack11p_0010\r\n" +
    "id:f6458d43-c111-4465-92e664898837e177\r\n" +
    "content-length:0\r\n" +
    "ack:client\r\n" +
    "\r\n" +
    "\x00"

nackp1 = "NACK\r\n" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "id:2\r\n" +
    "content-length:0\r\n"

nackp2 =  "\r\n" +
    "\x00"

unsubscribe = "UNSUBSCRIBE\r\n" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "destination:/queue/test.ruby.stomp.test_nack11p_0010\r\n" +
    "id:f6458d43-c111-4465-92e664898837e177\r\n" +
    "content-length:0\r\n" +
    "\r\n" +
    "\x00"

subscribe = "SUBSCRIBE\r\n" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "destination:/queue/test.ruby.stomp.test_nack11p_0010\r\n" +
    "id:eb56e791-8ed0-4792-b8122a77a9aa6bf3\r\n" +
    "content-length:0\r\n" +
    "ack:auto\r\n" +
    "\r\n" +
    "\x00"

disconnect = "DISCONNECT\r\n" +
    "content-type:text/plain; charset=UTF-8\r\n" +
    "content-length:0\r\n" +
    "\r\n" +
    "\x00"


part1 = false
part2 = false
both = true

if part1 || both
  # Session / Connection 1
  # Apollo, from: apache-apollo-99-trunk-20120929.031419-121-unix-distro.tar.gz
  sock = TCPSocket.new "localhost", 62613 # Apollo 
  # Connect - does not use \r\n because in general we can not know yet whether
  # the broker is a real 1.2 broker.
  puts "Connect 1"
  sock.write(connect) # CONNECT
  # Read CONNECTED
  msg = sock.readline("\0") # The CONNECTED message.  Drop it.
  p [ "CONNECTEDmsg", msg ]
  puts "Session Data 1"
  sock.write(sessdata_01) # SEND, SUBSCRIBE
  puts "Read message 1"
  msg = sock.readline("\0") # Read message
  p [ "msg", msg ]
  ack = msg.match /ack:(.*)\n/
  # puts $1
  so = "ack:" + $1 + "\r\n"
  # p [ "so", so ]
  puts "Send NACK"
  sock.write(nackp1 + so + nackp2) # NACK
  puts "Send UNSUBSCRIBE"
  sock.write(unsubscribe) # UNSUBSCRIBE
  puts "Disconnect 1"
  sock.write(disconnect) # DISCONNECT
  sock.close
end

if part2 || both
  # Session / Connection 2
  # Connect - does not use \r\n because in general we can not know yet whether
  # the broker is a real 1.2 broker.
  sock = TCPSocket.new "localhost", 62613 # Apollo 
  puts "Connect 2"
  sock.write(connect) # CONNECT
  # Read CONNECTED
  msg = sock.readline("\0") # The CONNECTED message.  Drop it.
  puts "Subscribe 2"
  sock.write(subscribe) # SUBSCRIBE
  # After the write of the SUBSCRIBE, apollo.log contains, e.g.:
  # 2012-10-26 12:25:07,258 | WARN  | java.io.IOException: Unable to parse header line [\u0013] | org.apache.activemq.apollo.broker.Broker | hawtdispatch-DEFAULT-1
  puts "Read 2 (expect message, get hang)" # Expect to re-receive the NACK'd message here
  msg2 = sock.readline("\0")
  p [ "msg2", msg2 ]
  puts "Disconnect 2"
  sock.write(disconnect) # DISCONNECT
  sock.close
end
puts "Done!"

