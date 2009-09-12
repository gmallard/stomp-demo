#
class StompHelper
  #
  class << self
    #
    def make_destination(qpart)
      "/queue#{qpart}"
    end
  end
end

