require 'logger'
#
require 'rubygems'
require 'eventmachine'
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require 'runparms'
#
# = StompSendSubscribeClient
#
# This is a _crude_ implementation of a stomp client using eventmachine.
#
# This client:
#
# 1) Connects to a running stompserver
# 2) Sends messages to a destination there
# 3) Subscribes to that destination
# 4) Processes the messages received on the subscription
#
# This code has been run against:
#
# * The ruby stompserver gem (locally modified for ruby 1.9.x compatability)
# * AMQ 5.3
#
# This code has been run using ruby 1.8, again with the locally modified 
# stompserver gem.  I have _not_ tested this against the standard 0.9.9
# ruby gem, but believe there should be no problems with it.
#
module StompSendSubscribeClient
  #
  # Leverage EM supplied stomp functionality.
  #
  include EM::Protocols::Stomp
  # Initialize the client instance
  def initialize(*args)
    super(*args)
    options = (Hash === args.last) ? args.pop : {}
    @conn_headers = {:login => "guest", :passcode => "guestpass"}
    @conn_headers.merge!(options)
    @connected = false
    @data_received = []
    #
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
  end

  # Post initialize
  def post_init
    @log.debug("#{self} post_init done")
  end

  # Called when successful connect is complete per docs
  def connection_completed
    connect @conn_headers   # call EM supplied CONNECT method
    @log.debug("#{self} connection_completed done")
  end

  # receive_msg - override of EM supplied method
  def receive_msg(msg)
    if msg.command == "CONNECTED"
      @log.debug("#{self} received CONNECTED : #{msg.inspect}")
      @connected = true
    else
      @log.debug("got a message: #{msg.inspect}")
      @log.debug("#{self} got a message")
      @data_received << msg   # accumulate messages
    end
  end

  # :stopdoc:

  # EM supplied the following Stomp methods only:
  #
  # * connect params={}
  # * send destination, body, params={}
  # * subscribe destination, ack=false
  # * ack msgid

  # :startdoc:

  #
  # Stomp - SUBSCRIBE
  #
  # Hook EM supplied method
  #
  def subscribe(dest, ack=false)
    @log.debug "#{self} subscribe hook starts"
    super(dest,ack)
    @log.debug "#{self} subscribe hook done"
  end

  #
  # Stomp - DISCONNECT
  #
  def disconnect()
    send_data("DISCONNECT\n\n\x00")
  end

  # :stopdoc:

  # Convenience methods

  # :startdoc:

  #
  # connected?
  #
  def connected?
    @connected
  end
  #
  # get_data_received
  #
  def get_data_received(&block)
    #
    return nil if @data_received == []
    return nil if !block_given?
    #
    @data_received.each do |message|
      yield message
    end
    @data_received = []
  end
end
#
@max_msgs = ENV['MAX_MSGS'] ? ENV['MAX_MSGS'].to_i : 1
#
@need_sends = true
@need_subscribe = false
@need_gets = false
#
@log = Logger.new(STDOUT)
@log.level = Logger::DEBUG
#
# Send some messages only once.
#
def send_a_message(conn, dest, message, headers={})
  return if not @need_sends 
  @log.debug "send_s_message starts"
  return if not conn.connected?
  1.upto(@max_msgs) do |mnum|
      outmsg = "#{message} |:| #{mnum}"
      conn.publish(dest, outmsg, headers) # EM supplied Stomp method
  end
  @need_sends = false
  @need_subscribe = true
  @log.debug "send_s_message done"
end
#
# Run a subscribe once.
#
def run_subscribe(conn, dest)
  return if not @need_subscribe
  @log.debug "run_subscribe starts"
  conn.subscribe(dest)  # call hook
  @log.debug  "run_subscribe done"
  @need_subscribe = false
  @need_gets = true
end
#
# Run some gets only once.
#
def run_gets(conn)
  return if not @need_gets
  @log.debug "run_gets starts"
  received_count = 0
  conn.get_data_received do |msg|
    received_count += 1
    @log.debug("-" * 20)
    @log.debug "Message Number #{received_count}:"
    #
    @log.debug("Type: #{msg.class}")
    @log.debug("Command: #{msg.command}")
    @log.debug("Header Information:")
    msg.header.each {|k,v|
      @log.debug("#{k}=#{v}")
    }
    @log.debug("Body:")
    @log.debug("#{msg.body}")
  end
  @log.debug "run_gets done"
  if received_count > 0
    #
    # We are done!
    #
    conn.disconnect()
    EventMachine::stop_event_loop()      
  end
  # Otherwise, wait for message arrival.
end
#
# The EM run method.
#
EM.run {
  @log.debug "EM.run starts"
  #
  runparms = Runparms.new
  port = runparms.port
  host = runparms.host
  #
  conn = EM.connect(host, port, StompSendSubscribeClient,
    :login => "gmallard", :passcode => "bigguy")
  @log.debug "EM.run Connection complete to #{host} on port #{port}"
  #
  # Send some messages
  #
  EventMachine::add_periodic_timer( 1 ) {
    message =  "A Test Message"
    dest = "/queue/emtest01"
    send_a_message(conn, dest, message)
  }
  #
  # Subscribe when sends are done
  #
  EventMachine::add_periodic_timer( 1 ) {
    dest = "/queue/emtest01"
    run_subscribe(conn, dest)
  }
  #
  # Subscribe should return messages.  Try to process them.
  #
  EventMachine::add_periodic_timer( 1 ) {
    run_gets(conn)
  }
  #
  @log.debug "EM.run done"
}

