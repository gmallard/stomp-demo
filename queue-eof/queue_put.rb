require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
#
# = Queue EOF Message Putter
#
# Show a +specialized+ stomp client which puts messages to a queue.
#
# This client has the ability to put a special EOF message on the queue
# at the end of processing.
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
    @queue_name = params[:queue_name] ? params[:queue_name] : "/queue/contrun"
    @client_id = params[:client_id] ? params[:client_id] : "ClientEOF0"
    @max_msgs = params[:max_msgs] ? params[:max_msgs] : 5
  end
  #
  # Put messages to a queue.
  #
  def put_messages
    for i in 1..@max_msgs do
       message = "Da Bears #{i}!"
       @@log.debug message
       @client.send(@queue_name, message,
         {"persistent" => true, "client-id" => @client_id,
          "reply-to" => @queue_name} )
    end
    # EOF message
    if @do_eow
      @@log.debug "putting end work message: #{Runparms::EOF_MSG}"
      @client.send(@queue_name, Runparms::EOF_MSG, {
        "persistent" => true,
        "client-id" => @client_id,
        "reply-to" => @queue_name,
        }
      )
    end
    @@log.debug "putter client ending"
    @client.close
  end
end
#
eow = false
eow = true if ARGV[0] =~ /true/i
putter = QEofMessagePutter.new(:do_eow => eow, :max_msgs => 3)
putter.put_messages


