#
require 'socket'
s = TCPSocket.new "localhost", 62613
# cd = "CONNECT\n" +
cd = "STOMP\n" +
  "login:me\n" +
  "passcode:pw\n" +
  "host:localhost\n" +
  "accept-version:1.2\n" +
  "\n" +
  "\x00"
p [ cd ]
s.write(cd)
puts "starting read ..."
d = s.readline("\0")
p [ d ]
s.close

