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
    secs_to_sleep = 3 # Choose this carefully depending on how long
                      # the processing of each message will take
    work_time = 0.050 # how long the work takes / pretty quick here
#    work_time = 2.9 # how long the work takes / this works but is like watching paint dry
    receive_end = Time.now
    @client.subscribe(@queue_name,
     {"persistent" => true, "client-id" => @client_id,
        'ack' => @ack} ) do |message|
      receive_end = Time.now
      @@log.debug "subscribe loop, thread is: #{Thread.current}"
      lmsg = "Got Reply: ID=#{message.headers['message-id']} "
      lmsg += "BODY=#{message.body} "
      lmsg += "on QUEUE #{message.headers['destination']}"
      @@log.debug "#{lmsg}"
      received = message
      count += 1
      #      
      procmsg(received, work_time)
      if @ack == "client"
        @@log.debug "subscribe loop, sending acknowledge"
        @client.acknowledge(received)
      end
    end
    # sleep until:
    # a) we have actually received some work, *AND*
    # b) we have actually processed each message (timing dependency here)
    sleep 0.1 until received && ((Time.now.to_i - receive_end.to_i) > secs_to_sleep)
    #
    @client.close
    @@log.debug "getter client received count: #{count}"
    @@log.debug "getter client ending, thread is: #{Thread.current}"
  end
  #
  # Simulate real work processing each message
  #
  def procmsg(message, work_time)
    sleep work_time # long running work
  end
end
#
qname = StompHelper.get_queue_name("/testbasic")
#
getter = BasicMessageGetter.new(:queue_name => qname )
getter.get_messages()
