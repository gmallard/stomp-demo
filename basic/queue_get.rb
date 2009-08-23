require 'rubygems'
require 'stomp'
#
# = Message Getter
#
# Show a very basic stompserver client which gets messages from a queue.
#
class MessageGetter
  #
  # Create new message getter.
  #
  def initialize
    @client = Stomp::Client.open "login", "passcode", "localhost", 51613
  end
  #
  # Get messages from a queue.
  #
  def get_messages
    received = nil
    @client.subscribe("/queue/test", {
                    "persistent" => true,
                    "client-id" => "rubyClient",
            } ) do |message|
      puts "Got Reply: ID=#{message.headers['message-id']} BODY=#{message.body} on #{message.headers['destination']}"
      received = message
    end
    sleep 0.1 until received
    @client.close
    puts "getter client ending"
  end
end
#
getter = MessageGetter.new
getter.get_messages

