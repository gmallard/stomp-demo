require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative '../lib/runparms'
  require_relative '../lib/stomphelper'
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "lib")
  require 'runparms'
  require 'stomphelper'
end

#
puts "start"
params = {}
runparms = Runparms.new(params)
use_port = runparms.port
use_port = ENV['STOMP_PORT'].to_i if ENV['STOMP_PORT']
puts runparms.userid
puts runparms.password
puts runparms.host
puts use_port
#
conn = Stomp::Connection.open(runparms.userid, runparms.password, 
  runparms.host, use_port)
#
conn_headers = {}
conn.publish "/queue/ackqt01", "msg01", conn_headers
conn.publish "/queue/ackqt01", "msg02", conn_headers
conn.publish "/queue/ackqt01", "msg03", conn_headers
#
conn.disconnect()
puts "done"

