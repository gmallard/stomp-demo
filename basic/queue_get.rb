require 'rubygems'
require 'stomp'
require 'logger'
#
# = Message Getter
#
# Show a very basic stompserver client which gets messages from a queue.
#
class MessageGetter
  #
  # Create new message getter.
  #
  def initialize(params)
    #
    # set defaults or overrides
    #
    @queue_name = params[:queue_name] ? params[:queue_name] : "/queue/testbasic"
    @client_id = params[:client_id] ? params[:client_id] : "Client1"
    #
    @client = Stomp::Client.open "login", "passcode", "localhost", 51613
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
  end
  #
  # Get messages from a queue.
  #
  def get_messages
    received = nil
    @@log.debug "getter client starting"
    @client.subscribe(@queue_name, {
                    "persistent" => true,
                    "client-id" => @client_id,
            } ) do |message|
      lmsg = "Got Reply: ID=#{message.headers['message-id']} "
      lmsg += "BODY=#{message.body} "
      lmsg += "on QUEUE #{message.headers['destination']}"
      @@log.debug "#{lmsg}"
      received = message
    end
    sleep 0.1 until received
    @client.close
    @@log.debug "getter client ending"
  end
end
#
# getter = MessageGetter.new(:queue_name => "/queue/testbasic")
getter = MessageGetter.new(:queue_name => "/queue/testbasic")
getter.get_messages

