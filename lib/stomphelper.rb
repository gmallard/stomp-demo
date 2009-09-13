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
  end # end of << self
end # end of StompHelper

