#
# = Stomp Server and Messaging Examples
#
# == Notes
#
# Initial examples are based on the code suplied with the stompserver gem.
#
# Initial configuration uses a non-default port, because I already have a 
# running instance of ActiveMQ which uses 61613.  The non-default port is
# 51613.
#
# This project is currently based on:
#
# stomp:: gem version 1.1
# stompserver:: gem version 0.9.9
#
# == Rdoc Generation
#
# To generate rdoc for this project, use:
#
# * rake doc:rdoc
#
# == Stompserver Start Options
#
# === Command Line Options
#
# Command line options for the stompserver are:
#
# -C, --config=CONFIGFILE:: Configuration File (default: stompserver.conf)
# -p, --port=PORT:: Change the port (default: 61613)
# -b, --host=ADDR:: Change the host (default: localhost)
# -q, --queuetype=QUEUETYPE:: Queue type (memory|dbm|activerecord|file) (default: memory)
# -w, --working_dir=DIR:: Change the working directory (default: current directory)
# -s, --storage=DIR:: Change the storage directory (default: .stompserver, relative to working_dir)
# -d, --debug:: Turn on debug messages
# -a, --auth:: Require client authorization
# -c, --checkpoint=SECONDS:: Time between checkpointing the queues in seconds (default: 0)
# -h, --help:: Show help message
#
# === Configuration File Options
#
# Configuration options can also be stored in a configuration file.  This is
# normally a YAML file named +stompserver.conf+ in the working directory. An
# example of such a configuration file is provided in this project.
#

