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
      sl_count = 0
      begin
        sl_count += 1
        @@log.debug "Monitor main sleeping, loop number: #{sl_count}"
        sleep 10
      end until received
      # Never get here.
    end
  end
  #
  private
  def proc_message(m)
    qlist = m.body.split("\n\n").sort
    @@log.info("=" * 30)
    qlist.each do |aq|
      top = aq.gsub("\n"," ")
      @@log.info("#{top}")
    end
  end
end
#
sqm = StompMonitor.new
sqm.run_monitor

