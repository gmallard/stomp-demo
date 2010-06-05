#
# = Test Instance
#
require 'logger'
$:.unshift File.join(File.dirname(__FILE__))
#
require 'connection'
require 'client'
#
class Test
  #
  def initialize(test_num, params = {})
    @test_num = test_num
    @params = params
    @log = Logger::new(STDOUT)
    @log.level = Logger::DEBUG
    #
    max_min = params[:max_concli] - params[:min_concli] + 1
    @num_runners = params[:min_concli] + rand(max_min)
    #
  end
  #
  def runtests
    @log.debug("Test instance #{@test_num} starts")
    @log.debug("Test instance #{@test_num}, num_runners: #{@num_runners}")
    start_runners
    join_runners
    @log.debug("Test instance #{@test_num} ends")
  end
  #
  def start_runners
    @log.debug("Test instance #{@test_num} start_runners starts")
    curconn = curcli = 0
    @runners = (1..@num_runners).map do |rn|
      Thread.new(@test_num, rn, @params) do |t_num, cc_num, cocl_params|
        cocl = nil
        if rn % 2 != 0
          curconn += 1
          cocl = Connection::new(t_num, curconn, cocl_params)
        else
          curcli += 1
          cocl = Client::new(t_num, curcli, cocl_params)
        end
        cocl.testcocl
      end
    end
    @log.debug("Test instance #{@test_num} start_runners ends")
  end
  #
  def join_runners
    @log.debug("Test instance #{@test_num} join_runners starts")
    @runners.each {|th| th.join}
    @log.debug("Test instance #{@test_num} join_runners ends")
  end
end

