#
# = Stommp Helper Container
#
class StompHelper
  #
  class << self
    #
    # Return a stomp queue name.
    #
    def make_destination(qpart)
      nospec = qpart.gsub(":","")
      qret = "/queue#{nospec}"
      if nospec[0..0] != "/"
        qret = "/queue/#{nospec}"
      end
      qret
    end
    #
    def get_queue_name(default)
      qname = ENV['QNAME'] ? ENV['QNAME'] : StompHelper::make_destination(default)
    end
    #
    def pause(consmsg)
      puts consmsg
      gets
    end
    #
    def get_maxmsgs(params = {:default => 10})
      max_msgs = ENV['MAX_MSGS'] ? ENV['MAX_MSGS'].to_i : params[:default]
    end
    #
  end # end of << self
end # end of StompHelper

