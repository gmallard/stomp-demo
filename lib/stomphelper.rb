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
      case
        when ARGV.size > 0 
          case
            when ARGV[0][0..0] == "-"
              qname = StompHelper::make_destination(default)
            else
              qname = StompHelper::make_destination(ARGV[0])
          end
        else
          qname = StompHelper::make_destination(default)
      end
    end
    #
    def pause(consmsg)
      puts consmsg
      gets
    end
  end # end of << self
end # end of StompHelper

