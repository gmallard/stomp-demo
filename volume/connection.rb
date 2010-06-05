#
require 'rubygems'
require 'stomp'
require 'logger'
#
class Connection
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
    @me = "T#{tnum}_#{ccnum}_con"
  end
  #
  def testcocl
    @log.debug("Connection instance #{@me} starts")
    @log.debug("Connection instance #{@me}, num_msgs: #{@num_msgs}")
    @log.debug("Connection instance #{@me} ends")
    #
    @conn = Stomp::Connection.new(@me, @me, @params[:host], @params[:port])
    @sess = @conn.connection_frame.headers['session']
    @log.debug("#{@me} - session: #{@sess}")
    @qname = "/queue/#{@me}_#{@sess}"
    @log.debug("#{@me} - qname: #{@qname}")
    #
    putmsgs
    sleep rand(5)*rand
    getmsgs
    #
    @conn.disconnect()
    #
    @log.debug("Connection instance #{@tnum}/#{@ccnum} ends")
  end
  #
  def putmsgs
    1.upto(@num_msgs) do |mnum|
      msg = "#{mnum} of #{@num_msgs}"
      @conn.publish(@qname, msg)
      @log.debug("#{@me} published #{msg}")
      sleep rand(3)*rand
    end
  end
  #
  def getmsgs
    @conn.subscribe(@qname)
    1.upto(@num_msgs) do |mnum|
      msg = @conn.receive
      @log.debug("#{@me} received #{msg.body}")
      sleep rand(3)*rand
    end
  end
end

