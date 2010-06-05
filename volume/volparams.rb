require 'yaml'
require 'optparse'
#
# = Volume Parameters
#
class Volparams
  #
  attr_reader :params
  #
  def initialize
    @params = defaults()
    #
    yfname = File.join(File.dirname(__FILE__), "volparams.yaml")
    yamlparms = {}
    if File.exists?(yfname)
      yamlparms = YAML.load(File.open(yfname))
      @params.merge!(yamlparms) if yamlparms
    end
    #
    @params.merge!(get_opts())
  end

  private
  # Parse command line options
  def get_opts()
    clopts = {}
    parser = OptionParser.new
    #

    # :min_tests
    parser.on("-t", "--min_tests=mintests", Integer, 
      "Minimum Tests (Default: 1)") {|x| 
      clopts[:min_tests] = x
    }

    # :max_tests
    parser.on("-u", "--max_tests=maxtests", Integer, 
      "Maximum Tests (Default: 1)") {|x| 
      clopts[:max_tests] = x
    }

    # :min_concli
    parser.on("-c", "--min_concli=minconnclients", Integer, 
      "Minimum Connections/Clients (Default: 1)") {|x| 
      clopts[:min_concli] = x
    }

    # :max_concli
    parser.on("-d", "--max_concli=maxconnclients", Integer, 
      "Maximum Connections/Clients (Default: 1)") {|x| 
      clopts[:max_concli] = x
    }

    # :min_msgs
    parser.on("-m", "--min_msgs=minmessages", Integer, 
      "Minimum Messages (Default: 1)") {|x| 
      clopts[:min_msgs] = x
    }

    # :max_msgs
    parser.on("-n", "--max_msgs=maxmessages", Integer, 
      "Maximum Messages (Default: 1)") {|x| 
      clopts[:max_msgs] = x
    }

    # :host
    parser.on("-s", "--server=SERVERNAME", String, 
      "Hostname of server (Default: localhost)") {|host| 
      clopts[:host] = host}

    # :port
    parser.on("-p", "--port=PORT", Integer,
      "Port number of server (Default: 51613)") {|port| 
      clopts[:port] = port}

    # Handle help if required
    parser.on("-h", "--help", "Show this message") do
      puts parser
      exit
    end
    # Run the parse
    parser.parse(ARGV)
    # Return found options
    clopts    
  end

  private
  def defaults()
    params = {}
    params[:min_tests] = 1
    params[:max_tests] = 1
    #
    params[:min_concli] = 1
    params[:max_concli] = 1
    #
    params[:min_msgs] = 1
    params[:max_msgs] = 1
    #
    params[:host] = 'localhost'
    params[:port] = 51613
    params
  end
end

