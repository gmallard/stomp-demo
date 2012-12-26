require 'rubygems'
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
# = Queue EOF Message Putter
#
# Show a +specialized+ stomp client which puts messages to a queue.
#
# This client has the ability to put a special EOF message on the queue
# at the end of processing.  This is accomplished by passing a command line
# parameter which contains the word "true" any where in it.  Case is not
# important.  Example:
#
# * ruby queue-eof/queue_put.rb "TrUe"
#
class QEofMessagePutter
  #
  # Create a new message putter.
  #
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    @runparms = Runparms.new
    # Just one client here
    @client = Stomp::Client.open(@runparms.userid, @runparms.password, 
      @runparms.host, @runparms.port)
    #
    @do_eow = params[:do_eow] ? params[:do_eow] : false
    @queue_name = params[:queue_name] ? params[:queue_name] : 
      StompHelper::make_destination("/contrun")
    @client_id = params[:client_id] ? params[:client_id] : "ClientEOF0"
    @max_msgs = params[:max_msgs] ? params[:max_msgs] : 5
  end
  #
  # Put messages to a queue.
  #
  def put_messages()
    headers = {"persistent" => true, 
          "client-id" => @client_id,
          "reply-to" => @queue_name}
    #
    for i in 1..@max_msgs do
       message = "Da Bears #{i}!"
       @@log.debug "#{self.class} #{message}"
       @client.publish(@queue_name, message, headers)
    end
    # EOF message
    if @do_eow
      @@log.debug "#{self.class} putting end work message: #{Runparms::EOF_MSG}"
      @client.publish(@queue_name, Runparms::EOF_MSG, headers)
    end
    @@log.debug "#{self.class} putter client ending"
    @client.close
  end
end
#
eow = ARGV[0] =~ /true/i ? true : false
qname = StompHelper.get_queue_name("/contrun")
max_msgs = StompHelper.get_maxmsgs(:default => 3)
putter = QEofMessagePutter.new(:do_eow => eow, :max_msgs => max_msgs,
  :queue_name => qname)
putter.put_messages()
