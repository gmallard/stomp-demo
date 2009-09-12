#
# = Stomp Queue Monitor
#
require 'rubygems'
require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'runparms'
require 'stomphelper'
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
    @@log.debug @runparms.to_s
  end
  #
  # Run the monitor
  #
  def run_monitor
    @@log.debug("Stomp queue monitor starts.")
    loop_count = 0
    #
    # Do this until the EOF message is received.
    #
    while (true)
      loop_count += 1
      @@log.debug "Monitor loop count: #{loop_count}"
      #
      client = Stomp::Client.open(@runparms.userid, @runparms.password, 
        @runparms.host, @runparms.port)
      received = nil
      client.subscribe(StompHelper::make_destination("/monitor"),
        {"persistent" => true, "client-id" => @client_id} ) do |message|
          proc_message(message)
          #
          # received = message
        end
      @@log.debug "Monitor main starting to sleep"
      sleep 5 until received
      # Never get here.
    end
  end
  #
  private
  def proc_message(m)
    @@log.debug("#{m.inspect}")
    to_print = m.body.gsub("\n"," ")
    @@log.info("#{to_print}")
  end
end
#
sqm = StompMonitor.new
sqm.run_monitor

