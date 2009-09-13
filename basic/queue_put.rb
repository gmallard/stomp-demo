require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
#
# = Basic Message Putter
#
# Show a very +basic+ stomp client which puts messages to a queue.
#
class BasicMessagePutter
  #
  attr_reader :queue_name, :client_id, :max_msgs
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
    @client_id = params[:client_id] ? params[:client_id] : "Client1"
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
  def put_messages
    for i in 1..@max_msgs do
       message = "Go Sox #{i}!"
       @@log.debug "#{message}"
       @client.send(@queue_name, message, 
        {"persistent" => true, "client-id" => @client_id, 
         "reply-to" => @queue_name} )
    end
    @@log.debug "putter client ending"
    @client.close
  end
  #
  # Return the string representation.
  #
  def to_s
    "max_msgs: #{max_msgs} queue_name: #{queue_name} client_id: #{client_id}"
  end
end
#
qname = ARGV[0] ? StompHelper::make_destination(ARGV[0]) :
  StompHelper::make_destination("/testbasic")
#
putter = BasicMessagePutter.new(:max_msgs => 10, 
  :queue_name => qname )
putter.put_messages


