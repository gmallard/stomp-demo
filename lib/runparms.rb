#
require 'logger'
require 'yaml'
#
class Runparms
  #
  Runparms::EOF_MSG = "__END_OF_WORK__"
  #
  attr_reader :userid, :password, :host, :port
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
    @@log.debug "YAML Parms File Name: #{yfname}"
    yaml_params = nil
    if File.exists?(yfname)
      @@log.debug "Exists!"
      yaml_parms = YAML.load(File.open(yfname))
      @@log.debug "YAML Parms: #{yaml_parms.inspect}"
      #
      @userid = yaml_parms[:user_id]
      @password = yaml_parms[:password]
      @host = yaml_parms[:host]
      @port = yaml_parms[:port]
    end
    #
    #
    # Override with CTOR parms.
    #
    @userid = params[:userid] if params[:userid]
    @password = params[:password] if params[:password]
    @host = params[:host] if params[:host]
    @port = params[:port] if params[:port]
    #
    # Last resort is hard coded values here.
    #
    @userid = "login" if not @userid
    @password = "passcode" if not @password
    @host = "localhost" if not @host
    @port = 51613 if not @port
  end
  #
  def to_s
    "Userid=#{@userid}, Password=#{@password}, Host=#{@host}, Port=#{@port}"
  end
end

