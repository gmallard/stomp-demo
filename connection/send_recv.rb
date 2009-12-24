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
    @@log.debug runparms.to_s
    @conn = Stomp::Connection.open(runparms.userid, runparms.password, 
      runparms.host, runparms.port)
  end
  #
  # Send messages using a connection.
  #
  def send_messages()
    @@log.debug("send_messages starts")
    for msgnum in (0..@max_msgs-1) do
      next_msg = "Message number: #{msgnum+1}"
      @@log.debug("Next to send: #{next_msg}")
      @conn.send @queue_name, next_msg
    end
  end
  #
  # Receive messages using a connection.
  #
  def get_messages()
    @@log.debug("get_messages starts")
    subscribe
    for msgnum in (0..@max_msgs-1) do
      message = @conn.receive
      @@log.debug("Received: #{message}")
    end

  end
  #
  # Run a clean disconnect
  #
  def shutdown()
    if @conn
      @conn.unsubscribe(@queue_name)
      @@log.debug("Unsubscribe complete")
      @conn.disconnect()
      @@log.debug("Disconnect complete")
    end
  end
  #
  private
  #
  # Subscribe to a destination.
  #
  def subscribe
    @conn.subscribe(@queue_name)
  end
end
#
maxmsgs = 1
maxmsgs = ARGV[0].to_i if ARGV[0]
parms = {:max_msgs => maxmsgs}
#
qname = nil
qname = ARGV[1] if ARGV[1]
parms[:queue_name] = qname if qname
#
csr = SenderReceiver.new(parms)
csr.send_messages()
csr.get_messages()
csr.shutdown()

