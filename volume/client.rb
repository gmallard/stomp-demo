#
require 'rubygems'
require 'stomp'
require 'logger'
#
class Client
  #
  def initialize(tnum, ccnum, params = {})
    @tnum = tnum
    @ccnum = ccnum
    @params = params
    #
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
    #
    @me = "T#{tnum}_#{ccnum}_cli"
  end
  #
  def testcocl
    @log.debug("Client instance #{@tnum}/#{@ccnum} starts")
    @log.debug("Client instance #{@tnum}/#{@ccnum} ends")
  end
end

