require 'rubygems'
require 'stomp'
require 'logger'
#
# = Queue EOF Message Getter
#
# Show a +specialized+ stomp client which gets messages from a queue.
#
# This client loops forever until a special EOF message is detected on
# the queue.
#
class QEofMessageGetter
  #
  # Create new message getter.
  #
  def initialize
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
  end
  #
  # Get messages from a queue.
  #
  def get_messages
    @@log.debug "get messages starts"
    #
    keep_running = true
    loop_count = 0
    #
    while (keep_running)
      loop_count += 1
      @@log.debug "Client loop count: #{loop_count}"
      received = nil
      @client = Stomp::Client.open "login", "passcode", "localhost", 51613
      @@log.debug "next subscribe starts"
      @client.subscribe("/queue/contrun", {
                    "persistent" => true,
                    "client-id" => "rubyClient",
            } ) do |message|
          @@log.debug "Got Reply: ID=#{message.headers['message-id']} BODY=#{message.body} on #{message.headers['destination']}"
          #
          proc_message(message)
          #
          if message.body == "__END_OF_WORK__"
            @@log.debug "should be done"
            keep_running = false
            break
          end
          received = message
        end
      @@log.debug "Starting to sleep"
      sleep 0.1 until received
      @@log.debug "Ending sleep"
      @client.close
      received = nil
      @@log.debug "getter client loop ending"
    end
    @@log.debug "getter client ending"
  end

  private
  def proc_message(m)
    @@log.debug "Processing: #{m.body}"
  end
end
#
getter = QEofMessageGetter.new
getter.get_messages

