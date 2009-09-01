require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
#
# = Basic Message Getter
#
# Show a very +basic+ stomp client which gets messages from a queue.
#
class BasicMessageGetter
  #
  attr_reader :queue_name, :client_id
  #
  # Create new message getter.
  #
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    # set defaults or overrides
    #
    @queue_name = params[:queue_name] ? params[:queue_name] : "/queue/testbasic"
    @client_id = params[:client_id] ? params[:client_id] : "Client1"
    runparms = Runparms.new(params)
    @@log.debug runparms.to_s
    #
    @client = Stomp::Client.open(runparms.userid, runparms.password, 
      runparms.host, runparms.port)
  end
  #
  # Get messages from a queue.
  #
  def get_messages
    @@log.debug "getter client starting, thread is: #{Thread.current}"
    received = nil
    #
    # Note: in the subscribe loop there is actually a separate
    # thread!!
    #
    @client.subscribe(@queue_name, {
                    "persistent" => true,
                    "client-id" => @client_id,
            } ) do |message|
      @@log.debug "subscribe loop, thread is: #{Thread.current}"
      lmsg = "Got Reply: ID=#{message.headers['message-id']} "
      lmsg += "BODY=#{message.body} "
      lmsg += "on QUEUE #{message.headers['destination']}"
      @@log.debug "#{lmsg}"
      received = message
    end
    sleep 0.1 until received
    @client.close
    @@log.debug "getter client ending, thread is: #{Thread.current}"
  end
end
#
getter = BasicMessageGetter.new(:queue_name => "/queue/testbasic")
getter.get_messages

