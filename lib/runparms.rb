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
    @@log.debug "YAML Parms: File Name: #{yfname}"
    yaml_params = nil
    if File.exists?(yfname)
      @@log.debug "YAML Parms: #{yfname} exists!"
      yaml_parms = YAML.load(File.open(yfname))
      @@log.debug "YAML Parms: #{yaml_parms.inspect}"
      #
      @userid = yaml_parms[:user_id]
      @password = yaml_parms[:password]
      @host = yaml_parms[:host]
      @port = yaml_parms[:port]
    end
    #
    # Override with CTOR parms or hard coded values.
    #
    @userid = params[:userid] = params[:userid] ?
      params[:userid] : "login"
    @password = params[:password] = params[:password] ?
      params[:password] : "passcode"
    @host = params[:host] = params[:host] ?
      params[:host] : "localhost"
    @port = params[:port] = params[:port] ?
      params[:port] : 51613
  end
  #
  def to_s
    "Userid=#{@userid}, Password=#{@password}, Host=#{@host}, Port=#{@port}"
  end
end

