require 'rubygems'
require 'stomp'
require 'logger'
#
# = Message Putter
#
# Show a very basic stompserver client which @@log.debug messages to a queue.
#
class MessagePutter
  #
  # Create a new message putter.
  #
  def initialize(do_eow)
    @client = Stomp::Client.open "login", "passcode", "localhost", 51613
    @do_eow = do_eow
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
  end
  #
  # Put messages to a queue.
  #
  def put_messages
    for i in 1..5 do
       message = "Da Bears #{i}!"
       @@log.debug message
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
      @@log.debug "putting end work message: #{eowmsg}"
      @client.send("/queue/contrun", eowmsg, {
        "persistent" => true,
        "client-id" => "Client1",
        "reply-to" => "/queue/contrun",
        }
      )
    end
    @@log.debug "putter client ending"
    @client.close
  end
end
#
do_eow = false
do_eow = true if ARGV[0] =~ /true/i
putter = MessagePutter.new(do_eow)
putter.put_messages


