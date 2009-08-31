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
    # set defaults or overrides
    #
    @max_msgs = params[:max_msgs] ? params[:max_msgs] : 5
    @queue_name = params[:queue_name] ? params[:queue_name] : "/queue/test"
    @client_id = params[:client_id] ? params[:client_id] : "Client1"
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


