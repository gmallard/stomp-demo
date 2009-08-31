#
require 'logger'
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
    @userid = params[:userid] ? params[:userid] : "login"
    @password = params[:password] ? params[:password] : "passcode"
    @host = params[:host] ? params[:host] : "localhost"
    @port = params[:port] ? params[:port] : 51613
  end
  #
  def to_s
    "Userid=#{@userid}, Password=#{@password}, Host=#{@host}, Port=#{@port}"
  end
end

