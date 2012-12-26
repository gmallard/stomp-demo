require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
#
# = Connection Sender and Receiver
#
# Show use of a stomp connection used to send and receive messages.
#
# To help debug a problem with the stomp client code and it's interaction
# with stompserver, and possibly AMQ as well.
#
$DEBUG = ENV['DEBUG'] ? ENV['DEBUG'] : false
#
class SenderReceiver
  #
  # Create a new sender/receiver
  #
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    # set defaults or overrides
    #
    @max_msgs = params[:max_msgs] ? params[:max_msgs] : 5
    @queue_name = params[:queue_name] ? params[:queue_name] : 
      StompHelper::make_destination("/sendrecv")
    @@log.debug("S/R Queue name: #{@queue_name}")
    #
    runparms = Runparms.new(params)
    #
    @ack = runparms.ack ? runparms.ack : "auto"
    @headers = { "ack" => @ack }
    #
    @@log.debug runparms.to_s
    @conn = Stomp::Connection.open(runparms.userid, runparms.password, 
      runparms.host, runparms.port)
    StompHelper::pause("after connection open") if $DEBUG
  end
  #
  # Send messages using a connection.
  #
  def send_messages()
    @@log.debug("send_messages starts")
    for msgnum in (0..@max_msgs-1) do
      next_msg = "Message number: #{msgnum+1}"
      @@log.debug("Next to send: #{next_msg}")
      @conn.publish @queue_name, next_msg
      StompHelper::pause("After first send") if (msgnum == 0 and $DEBUG)
    end
  end
  #
  # Receive messages using a connection.
  #
  def get_messages()
    @@log.debug("get_messages starts")
    subscribe
    StompHelper::pause("After subscribe") if $DEBUG
    for msgnum in (0..@max_msgs-1) do
      message = @conn.receive
      @@log.debug("Received: #{message}")
      if @ack == "client"
        @@log.debug("in receive, sending ACK")
        @conn.ack(message.headers["message-id"])  # ACK the message ID!
      end
      StompHelper::pause("After first receive") if (msgnum == 0 and $DEBUG)
    end

  end
  #
  # Run a clean disconnect
  #
  def shutdown()
    if @conn
      @conn.unsubscribe(@queue_name)
      @@log.debug("Unsubscribe complete")
      StompHelper::pause("After unsubscribe") if $DEBUG
      @conn.disconnect()
      @@log.debug("Disconnect complete")
      StompHelper::pause("After disconnect") if $DEBUG
    end
  end
  #
  private
  #
  # Subscribe to a destination.
  #
  def subscribe
    @conn.subscribe(@queue_name, @headers)
  end
end
#
qname = StompHelper.get_queue_name("/sendrecv")
max_msgs = StompHelper.get_maxmsgs()
#
csr = SenderReceiver.new(:max_msgs => max_msgs, 
  :queue_name => qname )
#
csr.publish_messages()
csr.get_messages()
csr.shutdown()

