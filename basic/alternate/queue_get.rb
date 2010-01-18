require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(Dir::pwd, "lib")
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
    @client_id = params[:client_id] ? params[:client_id] : "basic_get_cl01_alt"
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
    #
    # Choose this value carefully.  The value:
    #
    # * _must_ exceed the time it will take to receive the first message.
    # * _must_ exceed the maximum single message processing time
    #
    # However, the valus used _should_ be as small as possible!
    #
    secs_to_sleep = 5
    #
    # How long it takes to process a single message.
    #
    message_processing_time = 1.0
    #
    #
    #
    receive_start = Time.now
    @client.subscribe(@queue_name,
     {"persistent" => true, "client-id" => @client_id,
        'ack' => @ack} ) do |message|
      @@log.debug "subscribe loop, thread is: #{Thread.current}"
      lmsg = "Got Reply: ID=#{message.headers['message-id']} "
      lmsg += "BODY=#{message.body} "
      lmsg += "on QUEUE #{message.headers['destination']}"
      @@log.debug "#{lmsg}"
      received = message
      count += 1
      #      
      procmsg(received, message_processing_time)
      if @ack == "client"
        @@log.debug "subscribe loop, sending acknowledge"
        @client.acknowledge(received)
      end
      receive_start = Time.now
    end
    # sleep until:
    # a) a maximum specfied wait time after the last receive is exceeded
    sleep 0.5 until ((Time.now.to_i - receive_start.to_i) > secs_to_sleep)
    #
    @client.close
    @@log.debug "getter client received count: #{count}"
    @@log.debug "getter client ending, thread is: #{Thread.current}"
  end
  #
  # Simulate real work processing each message
  #
  def procmsg(message, message_processing_time)
    sleep message_processing_time # long running work
  end
end
#
qname = StompHelper.get_queue_name("/testbasic")
#
getter = BasicMessageGetter.new(:queue_name => qname )
getter.get_messages()
