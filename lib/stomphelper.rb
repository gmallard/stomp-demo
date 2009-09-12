#
class StompHelper
  #
  class << self
    #
    def make_destination(qpart)
      nospec = qpart.gsub(":","")
      qret = "/queue#{nospec}"
      if nospec[0..0] != "/"
        qret = "/queue/#{nospec}"
      end
      qret
    end
  end
end

