#
# = Run Parameters Data
#
# Instances of this class contain connection parameters for a given
# sromp server connection.
#
require 'logger'
require 'yaml'
#
class Runparms
  #
  Runparms::EOF_MSG = "__END_OF_WORK__"
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
    end
    #
    # Override with CTOR parms if present
    #
    @userid = params[:userid] if params[:userid]
    @password = params[:password] if params[:password]
    @host = params[:host] if params[:host]
    @port = params[:port] if params[:port]
    #
    # Override with hard coded values if still no definition
    #
    @userid = "login" if not @userid
    @password = "passcode" if not @password
    @host = "localhost" if not @host
    @port = 51613 if not @port
    #
  end
  #
  # Return string representation.
  #
  def to_s
    "Userid=#{@userid}, Password=#{@password}, Host=#{@host}, Port=#{@port}"
  end
end

