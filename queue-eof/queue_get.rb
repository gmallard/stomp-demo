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
  end
  #
  # Get messages from a queue.
  #
  def get_messages
    puts "get messages starts"
    #
    keep_running = true
    loop_count = 0
    #
    while (keep_running)
      loop_count += 1
      puts "Client loop count: #{loop_count}"
      received = nil
      @client = Stomp::Client.open "login", "passcode", "localhost", 51613
      puts "next subscribe starts"
      @client.subscribe("/queue/contrun", {
                    "persistent" => true,
                    "client-id" => "rubyClient",
            } ) do |message|
          puts "Got Reply: ID=#{message.headers['message-id']} BODY=#{message.body} on #{message.headers['destination']}"
          #
          proc_message(message)
          #
          if message.body == "__END_OF_WORK__"
            puts "should be done"
            keep_running = false
            break
          end
          received = message
        end
      puts "Starting to sleep"
      sleep 0.1 until received
      puts "Ending sleep"
      @client.close
      received = nil
      puts "getter client loop ending"
    end
    puts "getter client ending"
  end

  private
  def proc_message(m)
    puts "Processing: #{m.body}"
  end
end
#
getter = MessageGetter.new
getter.get_messages

