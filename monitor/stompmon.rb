#
# = Stomp Queue Monitor
#
# Subscribe to /queue/monitor, per the stompserver gem README, and output
# the current statistics for existing queues.
#
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
#
class StompMonitor
  #
  # Initialize all run parameters.
  #
  def initialize(params = {})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    @runparms = Runparms.new
    @@log.debug "#{self.class} #{@runparms}"
  end
  #
  # Run the monitor
  #
  def run_monitor()
    @@log.debug("#{self.class} Stomp queue monitor starts.")
    loop_count = 0
    #
    headers = {"persistent" => true, "client-id" => "monitor-client"}
    #
    while (true)
      loop_count += 1
      @@log.debug "#{self.class} Monitor loop count: #{loop_count}"
      #
      client = Stomp::Client.open(@runparms.userid, @runparms.password, 
        @runparms.host, @runparms.port)
      received = nil
      client.subscribe(StompHelper::make_destination("/monitor"),
        headers) do |message|
          proc_message(message)
          #
          # received = message
        end
      sl_count = 0
      begin
        sl_count += 1
        @@log.debug "#{self.class} Monitor main sleeping, loop number: #{sl_count}"
        sleep 10
      end until received
      # Never get here.
    end
  end
  #
  private
  def proc_message(message)
    qlist = message.body.split("\n\n").sort
    @@log.info("=" * 30)
    qlist.each do |aq|
      top = aq.gsub("\n"," ")
      @@log.info("#{top}")
    end
  end
end
#
sqm = StompMonitor.new()
sqm.run_monitor()
