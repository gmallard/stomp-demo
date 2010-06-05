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
    max_min = params[:max_msgs] - params[:min_msgs] + 1
    @num_msgs = params[:min_msgs] + rand(max_min)
    #
    @me = "T#{tnum}_#{ccnum}_cli"
  end
  #
  def testcocl
    @log.debug("Client instance #{@me} starts")
    @log.debug("Client instance #{@me}, num_msgs: #{@num_msgs}")
    #
    @stcli = Stomp::Client.open(@me, @me, @params[:host], @params[:port])
    @sess = @stcli.connection_frame.headers['session']
    @log.debug("#{@me} - session: #{@sess}")
    @qname = "/queue/#{@me}_#{@sess}"
    @log.debug("#{@me} - qname: #{@qname}")
    #
    putmsgs
    getmsgs
    #
    @stcli.close
    #
    @log.debug("Client instance #{@me} ends")
  end
  #
  def putmsgs
    1.upto(@num_msgs) do |mnum|
      msg = "#{mnum} of #{@num_msgs}"
      @stcli.publish(@qname, msg)
      @log.debug("#{@me} published #{msg}")
    end
  end
  #
  def getmsgs
    count = 0
    @stcli.subscribe(@qname) do |msg|
      @log.debug("#{@me} received #{msg.body}")
      count += 1
    end
    #
    sleep 0.1 until count == @num_msgs
  end
end

