require 'rubygems'
require 'stomp'
require 'logger'
#
# = Message Putter
#
# Show a very basic stompserver client which puts messages to a queue.
#
class MessagePutter
  #
  # Create a new message putter.
  #
  def initialize(params)
    #
    @max_msgs = 5
    @max_msgs = params[:max_msgs] if params[:max_msgs]
    #
    @queue_name = "/queue/test"
    @queue_name = params[:queue_name] if params[:queue_name]
    #
    @client_id = "Client1"
    @client_id = params[:client_id] if params[:client_id]
    #
    @client = Stomp::Client.open "login", "passcode", "localhost", 51613
    #
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
  end
  #
  # Put messages to a queue.
  #
  def put_messages
    for i in 1..@max_msgs do
       message = "Go Sox #{i}!"
       @@log.debug "#{message}"
       @client.send(@queue_name, message, {
        "persistent" => true,
        "client-id" => @client_id,
        "reply-to" => @queue_name,
        }
      )
    end
    @@log.debug "putter client ending"
    @client.close
  end
end
#
putter = MessagePutter.new(:max_msgs => 10, :queue_name => "/queue/testbasic")
putter.put_messages


