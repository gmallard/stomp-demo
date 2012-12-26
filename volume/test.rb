#
# = Test Instance
#
require 'logger'

if Kernel.respond_to?(:require_relative)
  require_relative 'connection'
  require_relative 'client'
else
  $:.unshift File.join(File.dirname(__FILE__))
  require 'connection'
  require 'client'
end

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
    curconn = curcli = lcr = 0
    @runners = (1..@num_runners).map do |rn|
      lcr += 1
      sleep rand(lcr)
      Thread.new(@test_num, rn, @params) do |t_num, cc_num, cocl_params|
        cocl = nil
        if rn % 2 != 0
          curconn += 1
          Thread.current["tid"] = "T#{t_num}_#{curconn}_con"
          cocl = Connection::new(t_num, curconn, cocl_params)
        else
          curcli += 1
          Thread.current["tid"] = "T#{t_num}_#{curcli}_cli"
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
    @runners.each {|th|
      begin
        th.join
        @log.debug("Test join complete: #{th['tid']}")
      rescue RuntimeError => e
        @log.debug("Test join ERROR: #{th['tid']} - #{e.message}")
      end
    }
    @log.debug("Test instance #{@test_num} join_runners ends")
  end
end

