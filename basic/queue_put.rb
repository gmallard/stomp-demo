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
# = Basic Message Putter
#
# Show a very +basic+ stomp client which puts messages to a queue.
#
class BasicMessagePutter
  # The destination / queue to use
  attr_reader :queue_name
  # The client ID on the server
  attr_reader :client_id
  # Maximum messages to send
  attr_reader :max_msgs
  #
  # Create a new message putter.
  #
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    # set defaults or overrides
    #
    @max_msgs = params[:max_msgs] ? params[:max_msgs] : 5
    @queue_name = params[:queue_name] ? params[:queue_name] : 
      StompHelper::make_destination("/test")
    @@log.debug("Put Queue name: #{@queue_name}")
    @client_id = params[:client_id] ? params[:client_id] : "basic_put_cl01"
    #
    runparms = Runparms.new(params)
    @@log.debug runparms.to_s
    @client = Stomp::Client.open(runparms.userid, runparms.password, 
      runparms.host, runparms.port)
    #
  end
  #
  # Put messages to a queue.
  #
  def put_messages()
    #
    for i in 1..@max_msgs do
       message = "Go Sox #{i}!"
       @@log.debug "#{message}"
       @client.publish(@queue_name, message, 
        {"persistent" => true, "client-id" => @client_id, 
         "reply-to" => @queue_name} )
    end
    @client.close
    @@log.debug("queue_put completes")
  end
  #
  # Return the string representation.
  #
  def to_s()
    "max_msgs: #{max_msgs} queue_name: #{queue_name} client_id: #{client_id}"
  end
end
#
qname = StompHelper.get_queue_name("/testbasic")
max_msgs = StompHelper.get_maxmsgs()
#
putter = BasicMessagePutter.new(:max_msgs => max_msgs, 
  :queue_name => qname )
putter.put_messages()
