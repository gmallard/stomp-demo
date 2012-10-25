#
require 'socket'
s = TCPSocket.new "localhost", 62613
# cd = "CONNECT\r\n" +
cd = "STOMP\r\n" +
  "login:me\r\n" +
  "passcode:pw\r\n" +
  "host:localhost\r\n" +
  "accept-version:1.2\r\n" +
  "\r\n" +
  "\x00"
p [ cd ]
s.write(cd)
puts "starting read ..."
d = s.readline("\0")
p [ d ]
s.close

