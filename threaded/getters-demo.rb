#
# = ThreadedGetters
#
# Show an example with the following characteristics:
#
# * A putter knows how many getters (n) will be processing messages
# * The putter evenly distributes messages across (n) queues 
# * (n) getter threads are started, and process messages
#
require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
#
class ThreadedGetters
  #
  attr_reader :getters
  #
  # Initialize all run parameters.
  #
  def initialize(params = {})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    @queue_name_base = params[:queue_name_base] ? 
      params[:queue_name_base] : StompHelper::make_destination("/testbasic")
    @max_getters = params[:max_getters] ? 
      params[:max_getters] : 2 - 1
    @max_wke = params[:max_wke] ? 
      params[:max_wke] : 2 - 1
    #
    @getters = nil
    @runparms = Runparms.new
    #
    @@log.debug "Max Gettters: #{@max_getters + 1}"
    @@log.debug "Max WKEs: #{@max_wke + 1}"
  end
  #
  # Start (n) getter threads.  Each thread runs until it's individual
  # input queue is empty.
  #
  def start_getters
    #
    @getters = (0..@max_getters).map do |i|
      Thread.new("consumer #{i}", i) do |name, getter_num|
        client = Stomp::Client.open(@runparms.userid, @runparms.password, 
          @runparms.host, @runparms.port)
        received = nil
        client_name = "GetterClient#{getter_num}"
        client.subscribe(queue_name(getter_num), {
                        "persistent" => true,
                        "client-id" => client_name,
                } ) do |message|
          # @@log.debug "#{p message}"
          lmsg = "#{name} Got Reply: BODY=#{message.body} "
          lmsg += "on QUEUE #{message.headers['destination']}"
          @@log.debug "#{lmsg}"
          proc_message(message)
          received = message
        end
        sleep 0.5 until received
        client.close
        @@log.debug "getter #{name} ending"
      end
    end
  end
  #
  # Run the main putter.
  #
  # * Distribute messages across (n) queues.
  #
  def run_putter
    client = Stomp::Client.open(@runparms.userid, @runparms.password, 
      @runparms.host, @runparms.port)
    @@log.debug "starting puts"
    next_queue_num = @max_getters
    for i in 0..@max_wke do
       next_queue_num += 1
       next_queue_num = 0 if next_queue_num > @max_getters
       run_queue_name = queue_name(next_queue_num)
       client_name = "PutterClient#{next_queue_num}"
       message = "WKE Num: #{i} to queue #{run_queue_name}"
       @@log.debug "Putting: #{message}"
       client.send(run_queue_name, message, {
        "persistent" => true,
        "client-id" => client_name,
        "reply-to" => run_queue_name,
        }
      )
    end
    @@log.debug "ending puts"
    client.close
  end
  #
  # Real work should occur here.
  #
  private
  def proc_message(m)
    @@log.debug "Processing: #{m.body}"
  end
  #
  # Convenience method for obtaining a queue name.
  #
  def queue_name(nxtn)
    "#{@queue_name_base}#{nxtn}"
  end
end
#
threader = ThreadedGetters.new
threader.run_putter
puts "Starting putter"
threader.start_getters
puts "Starting getter wait"
threader.getters.each {|th| th.join}
puts "Complete"

