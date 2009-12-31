#
# = Run Parameters Data
#
# Instances of this class contain connection parameters for a given
# sromp server connection.
#
require 'logger'
require 'yaml'
require 'optparse'
#
class Runparms
  #
  Runparms::EOF_MSG = "__END_OF_WORK__"
  #
  # The ack mode to use on subscribe
  #
  attr_reader :ack
  #
  # The user ID to connect with.
  #
  attr_reader :userid
  #
  # The user's password.
  #
  attr_reader :password
  #
  # The stompserver host name or IP address to connect to.
  #
  attr_reader :host
  #
  # The stompserver listening port.
  #
  attr_reader :port
  #
  # Initialize runtime connection parameters.
#
  def initialize(params={})
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG
    #
    @userid, @password, @host, @port = nil, nil, nil, nil
    @ack = nil
    #
    # Properties from YAML file first.
    #
    yfname = File.join(File.dirname(__FILE__), "..", "props.yaml")
    yaml_params = {}
    if File.exists?(yfname)
      @@log.debug "YAML Parms: #{yfname} exists!"
      yaml_parms = YAML.load(File.open(yfname))
      @@log.debug "YAML Parms: #{yaml_parms.inspect}"
      #
      @userid = yaml_parms[:userid]
      @password = yaml_parms[:password]
      @host = yaml_parms[:host]
      @port = yaml_parms[:port]
      @ack = yaml_parms[:ack]
    end
    #
    # Override with CTOR parms if present
    #
    @userid = params[:userid] if params[:userid]
    @password = params[:password] if params[:password]
    @host = params[:host] if params[:host]
    @port = params[:port] if params[:port]
    @ack = params[:ack] if params[:ack]
    #
    clopts = get_opts()
    @userid = clopts[:userid] if clopts[:userid]
    @password = clopts[:password] if clopts[:password]
    @host = clopts[:host] if clopts[:host]
    @port = clopts[:port] if clopts[:port]
    @ack = clopts[:ack] if clopts[:ack]
    #
    # Override with hard coded values if still no definition
    #
    @userid = "login" if not @userid
    @password = "passcode" if not @password
    @host = "localhost" if not @host
    @port = 51613 if not @port
    @ack = "auto" if not @ack
    #
  end
  #
  # Return string representation.
  #
  def to_s
    "Userid=#{@userid}, Password=#{@password}, Host=#{@host}, Port=#{@port}, Ack=#{ack}"
  end

  private
  # Parse command line options
  def get_opts()
    clopts = {}
    parser = OptionParser.new

    # :ack
    parser.on("-a", "--ack=ackmode", String, 
      "Ack Mode (Default: auto)") {|am| 
      clopts[:ack] = am}

    # :userid
    parser.on("-u", "--user=LOGINID", String, 
      "Server user id (Default: login)") {|lid| 
      clopts[:userid] = lid}

    # :password
    parser.on("-p", "--password=PASSWORD", String, 
      "Server password (Default: passcode)") {|pw| 
      clopts[:password] = pw}

    # :host
    parser.on("-s", "--server=SERVERNAME", String, 
      "Hostname of server (Default: localhost)") {|host| 
      clopts[:host] = host}

    # :port
    parser.on("-P", "--port=PORT", Integer,
      "Port number of server (Default: 51613)") {|port| 
      clopts[:port] = port}

    # Handle help if required
    parser.on("-h", "--help", "Show this message") do
      puts parser
      exit
    end
    # Run the parse
    parser.parse(ARGV)
    # Return found options
    clopts    
  end
end

