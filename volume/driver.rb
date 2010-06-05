#
# = Volume Driver
#
# Driver code for volume / stress tests.
#
# == Purpose
#
# This is meant to place high volume on:
#
# * The Ruby stomp client
# * The stomp broker used
#
# require 'rubygems'
# require 'stomp'
require 'logger'
$:.unshift File.join(File.dirname(__FILE__))
#
#
#
require 'volparams'
require 'test'
#
# --------------------------------------------------------------------
#
=begin

== Requirements

* One or more command line driver instances are supported
* a-b Test Instances per driver
* Each test instance is assigned a unique ID (name)
* Each test instance uses either connection(s) or client(s) but not both
* c-d connection(s) or client(s) per test instance

Each connection/client:

* is assigned a unique ID (name)
* is assigned e-f random message count
* uses a unique queue name

Each message sent/received contains:

* Test instance ID
* Type of instance (connection/client)
* Connection/client ID
* Session-id of the server session
* Message number
* Total message count for this connection/client

== Implementation

* Test instances are individual threads
* Connection/client instances are individual threads

=end
#
# --------------------------------------------------------------------
#
class Driver
  #
  @@log = Logger::new(STDOUT)
  @@log.level = Logger::DEBUG
  #
  def initialize
    vpn = Volparams.new
    @volparams = vpn.params
  end
  #
  def run
    @@log.debug("driver run starts")
    @@log.debug("volparams: #{@volparams.inspect}")
    ltn = 0
    @tests = (@volparams[:min_tests]..@volparams[:max_tests]).map do |tn|
      ltn += 1
      sleep rand(ltn)
      Thread.new(tn, @volparams) do |test_num, test_params|
        Thread.current["tid"] = "TT_#{test_num}"
        @@log.debug("Test Thread #{test_num} starts")
        test_instance = Test.new(test_num, test_params)
        test_instance.runtests
        @@log.debug("Test Thread #{test_num} ends")
      end
    end
    @@log.debug("driver run ends")
  end
  #
  def joins
    @@log.debug("driver joins starts")
    @tests.each {|th| 
      begin
        th.join
        @@log.debug("Drive join complete for: #{th['tid']}")
      rescue RuntimeError => e
        @@log.debug("Drive join ERROR: #{th['tid']} - #{e.message}")
      end
    }
    @@log.debug("driver joins ends")
  end
end
#
drv = Driver.new
drv.run
drv.joins

