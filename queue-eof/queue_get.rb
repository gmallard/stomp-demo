require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
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
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    @runparms = Runparms.new
    @@log.debug @runparms.to_s
    #
    @queue_name = params[:queue_name] ? params[:queue_name] : 
      StompHelper::make_destination("/contrun")
    @client_id = params[:client_id] ? params[:client_id] : "rubyClient"
  end
  #
  # Get messages from a queue.  Keep running until a specially formatted
  # message which signals "end of work" is received.
  #
  def get_messages()
    @@log.debug "#{self.class} get messages starts"
    #
    eof_msg_not_received = true
    loop_count = 0
    #
    headers = {"persistent" => true, "client-id" => @client_id}
    #
    # Do this until the EOF message is received.
    #
    while (eof_msg_not_received)
      loop_count += 1
      @@log.debug "Client loop count: #{loop_count}"
      #
      client = Stomp::Client.open(@runparms.userid, @runparms.password, 
        @runparms.host, @runparms.port)
      @@log.debug "next subscribe starts"
      received = nil
      client.subscribe(@queue_name, headers ) do |message|
          #
          lmsg = "Got Reply: ID=#{message.headers['message-id']} "
          lmsg += "BODY=#{message.body} "
          lmsg += "on QUEUE #{message.headers['destination']}"
          @@log.debug "#{lmsg}"
          #
          proc_message(message)
          #
          if message.body == Runparms::EOF_MSG
            @@log.debug "#{self.class} should be done"
            eof_msg_not_received = false
            break
          end
          received = message
        end
      @@log.debug "#{self.class} Starting to sleep"
      sleep 0.1 until received
      @@log.debug "#{self.class} Ending sleep"
      client.close()
      received = nil
      @@log.debug "#{self.class} getter client loop ending"
    end
    @@log.debug "#{self.class} getter client ending"
  end

  private
  def proc_message(m)
    @@log.debug "Processing: #{m.body}"
  end
end
#
getter = QEofMessageGetter.new()
getter.get_messages()
