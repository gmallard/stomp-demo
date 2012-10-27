require 'stomp'
#
hash = { :hosts => [ 
  {:login => "guest", :passcode => "guest", :host => "localhost", :port => 62613, :ssl => nil},
  ],
  :reliable => false,
  :connect_headers => {"host" => "localhost", "accept-version" => "1.2"},
  :stompconn => false,
  :usecrlf => true,
}
#
reconn = true
#
q = "/queue/a"
m = "A message"
conn = Stomp::Connection.new(hash)
conn.publish(q, m, :k1 => "v1", :k2 => "v2")

if reconn
  conn.disconnect
  conn = Stomp::Connection.new(hash)
end

sid = conn.uuid()
conn.subscribe(q, :id => sid)
msg = conn.receive

p [ "msgh", msg.headers ]
puts "================="
msg.headers.each_pair do |k,v|
  p ["key:", k, "value:", v]
end
conn.disconnect

