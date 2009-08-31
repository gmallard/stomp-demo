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
  def initialize
    @client = Stomp::Client.open "login", "passcode", "localhost", 51613
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
  end
  #
  # Put messages to a queue.
  #
  def put_messages
    for i in 1..5 do
       message = "Go Sox #{i}!"
       @@log.debug "#{message}"
       @client.send("/queue/test", message, {
        "persistent" => true,
        "client-id" => "Client1",
        "reply-to" => "/queue/test",
        }
      )
    end
    @@log.debug "putter client ending"
    @client.close
  end
end
#
putter = MessagePutter.new
putter.put_messages


