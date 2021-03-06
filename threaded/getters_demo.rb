#
# = ThreadedGetters
#
# Show an example with the following characteristics:
#
# * A putter knows how many getters (n) will be processing messages
# * The putter evenly distributes messages across (n) queues 
# * (n) getter threads are started, and process messages
# * getter threads may be started before the putter runs
#
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
class ThreadedGetters
  # Getter thread list.
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
      params[:max_getters] : 3 - 1
    @max_wke = params[:max_wke] ? 
      params[:max_wke] : 100 - 1
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
  def start_getters()
    #
    @getters = (0..@max_getters).map do |i|
      Thread.new("consumer #{i}", i) do |name, getter_num|
        client = Stomp::Client.open(@runparms.userid, @runparms.password, 
          @runparms.host, @runparms.port)
        received = nil
        client_name = "GetterClient#{getter_num}"
        lmsg = "thread loop, thread is: #{Thread.current}, "
        lmsg += "client #{client_name}, "
        lmsg += "name #{name}"
        @@log.debug "#{lmsg}"
      	lcount = 0
        client.subscribe(queue_name(getter_num), {
                        "persistent" => true,
                        "client-id" => client_name,
                } ) do |message|
          @@log.debug "subscribe loop, thread is: #{Thread.current}, client #{client_name}"
          lmsg = "#{name} Got Reply: BODY=#{message.body} "
          lmsg += "on QUEUE #{message.headers['destination']}"
          @@log.debug "#{lmsg}"
          proc_message(message)
      	  lcount += 1
          received = message
          Thread::pass()
        end
        sleep 30 until received
#        sleep until received
        client.close
        @@log.debug "getter #{name} ending, count #{lcount}"
      end
    end
  end
  #
  # Run the main putter.
  #
  # * Distribute messages across (n) queues.
  #
  def run_putter()
    client = Stomp::Client.open(@runparms.userid, @runparms.password, 
      @runparms.host, @runparms.port)
    @@log.debug "#{self.class} starting puts"
    next_queue_num = @max_getters
    for i in 0..@max_wke do
       next_queue_num += 1
       next_queue_num = 0 if next_queue_num > @max_getters
       run_queue_name = queue_name(next_queue_num)
       client_name = "PutterClient#{next_queue_num}"
       message = "WKE Num: #{i} to queue #{run_queue_name}"
       @@log.debug "Putting: #{message}"
       #
       headers = {"persistent" => true,
          "client-id" => client_name,
          "reply-to" => run_queue_name,
        }
      #
       client.publish(run_queue_name, message, headers )
    end
    @@log.debug "#{self.class} ending puts"
    client.close
  end
  #
  # Real work should occur here.
  #
  private
  def proc_message(message)
    @@log.debug "Processing: #{message.body}"
    sleep rand(0.1)
  end
  #
  # Convenience method for obtaining a queue name.
  #
  def queue_name(next_name)
    "#{@queue_name_base}#{next_name}"
  end
end
#
threader = ThreadedGetters.new()
puts "Starting putter"
#
# The order in which getters/putters only matters in terms of
# performance.
#
# threader.run_putter()
# threader.start_getters()
#
threader.start_getters()
threader.run_putter()
#
puts "Starting getter wait"
threader.getters.each {|th| th.join}
puts "Complete"

