require 'rubygems'
require 'stomp'
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
    @do_eow = true
  end
  #
  # Put messages to a queue.
  #
  def put_messages
    for i in 1..5 do
       message = "Da Bears #{i}!"
       puts message
       @client.send("/queue/contrun", message, {
        "persistent" => true,
        "client-id" => "Client1",
        "reply-to" => "/queue/contrun",
        }
      )
    end
    # EOF message
    if @do_eow
      eowmsg = "__END_OF_WORK__"
      puts "putting end work message: #{eowmsg}"
      @client.send("/queue/contrun", eowmsg, {
        "persistent" => true,
        "client-id" => "Client1",
        "reply-to" => "/queue/contrun",
        }
      )
    end
    puts "putter client ending"
    @client.close
  end
end
#
putter = MessagePutter.new
putter.put_messages


