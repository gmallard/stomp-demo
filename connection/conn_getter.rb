require 'rubygems' if RUBY_VERSION =~ /1\.8/
require 'stomp'
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative '../lib/runparms'
  require_relative '../lib/stomphelper'
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "lib")
  require 'runparms'
  require 'stomphelper'
end

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
class ConectionReceiver
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
        @@log.debug("in receive, sending ACK, headers: #{message.headers.inspect}")
        message_id = message.headers["message-id"]
        @@log.debug("in receive, sending ACK, message-id: #{message_id}")
        @conn.ack(message_id) # ACK this message
      end
      StompHelper::pause("After first receive") if (msgnum == 0 and $DEBUG)
      #
      received = message
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
    @@log.debug("subscribe to: #{@queue_name}")
    @@log.debug("headers: #{@headers.inspect}")
  end
end
#
qname = StompHelper.get_queue_name("/sendrecv")
max_msgs = StompHelper.get_maxmsgs()
#
csr = ConectionReceiver.new(:max_msgs => max_msgs, 
  :queue_name => qname )
#
csr.get_messages()
csr.shutdown()

