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
class ConectionSender
  #
  # Create a new sender connection sender
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
    @headers = { "ack" => @ack, "client-id" => "conn_putter" }
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
      @conn.publish @queue_name, next_msg, @headers
      StompHelper::pause("After first send") if (msgnum == 0 and $DEBUG)
    end
  end
  #
  # Run a clean disconnect
  #
  def shutdown()
    if @conn
      @@log.debug("Unsubscribe complete")
      StompHelper::pause("After unsubscribe") if $DEBUG
      @conn.disconnect()
      @@log.debug("Disconnect complete")
      StompHelper::pause("After disconnect") if $DEBUG
    end
  end
  #
end
#
qname = StompHelper.get_queue_name("/sendrecv")
max_msgs = StompHelper.get_maxmsgs()
#
csr = ConectionSender.new(:max_msgs => max_msgs, 
  :queue_name => qname )
#
csr.publish_messages()
csr.shutdown()

