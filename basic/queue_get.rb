require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
#
# = Basic Message Getter
#
# Show a very +basic+ stomp client which gets messages from a queue.
#
class BasicMessageGetter
  # The queue name / destination to use
  attr_reader :queue_name
  # The client ID used on the server
  attr_reader :client_id
  # Ack Mode
  attr_reader :ack
  #
  # Create new message getter.
  #
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    # set defaults or overrides
    #
    @queue_name = params[:queue_name] ? params[:queue_name] : 
      StompHelper::make_destination("/testbasic")
    @@log.debug("Get Queue name: #{@queue_name}")
    @client_id = params[:client_id] ? params[:client_id] : "basic_get_cl01"
    runparms = Runparms.new(params)
    @@log.debug runparms.to_s
    @ack = runparms.ack ? runparms.ack : "auto"
    #
    @client = Stomp::Client.open(runparms.userid, runparms.password, 
      runparms.host, runparms.port)
  end
  #
  # Get messages from a queue.
  #
  def get_messages()
    @@log.debug "getter client starting, thread is: #{Thread.current}"
    received = nil
    #
    # Note: in the subscribe loop there is actually a separate
    # thread, known as the 'callback listener'!.
    #
    count = 0
    @client.subscribe(@queue_name,
     {"persistent" => true, "client-id" => @client_id,
        "ack" => @ack} ) do |message|
      @@log.debug "subscribe loop, thread is: #{Thread.current}"
      lmsg = "Got Reply: ID=#{message.headers['message-id']} "
      lmsg += "BODY=#{message.body} "
      lmsg += "on QUEUE #{message.headers['destination']}"
      @@log.debug "#{lmsg}"
      received = message
      count += 1
      if @ack == "client"
        @@log.debug "subscribe loop, sending acknowledge"
        @client.acknowledge(received)
      end
    end
    #
    # Make sure this sleep time is sufficiently large, but only as large as
    # really required!  There must be sufficient time for:
    # 1) The stomp server to dequeue all the messages in the queue
    # 2) The stomp server will then transmit these messages
    # 3) The consumer/getter (this code) then processes the messages received.
    #
    # If this is not done, this consumer/getter will appear to 'lose' messages,
    # because the main thread wakes up, sees 'received', and closes the client
    # connection prematurely.
    #
    # This anomaly is *much* more apparent with stompserver than with AMQ.  It
    # appears to me that AMQ enqueues, and dequeues messages much more quickly,
    # which covers this up in many cases.
    #
    # Later note:  The above paragraph may not be correct.  Caution advised.
    #
    sleep 3 until received
    #
    @client.close
    @@log.debug "getter client received count: #{count}"
    @@log.debug "getter client ending, thread is: #{Thread.current}"
  end
end
#
qname = StompHelper.get_queue_name("/testbasic")
#
getter = BasicMessageGetter.new(:queue_name => qname )
getter.get_messages()
