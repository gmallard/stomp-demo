#
# = Stomp Messaging Client Examples
#
# == Notes
#
#
# Initial examples are based on the code suplied with the stompserver gem,
# and with tests from the stomp gem.
#
# The default configuration in this project uses a non-default port for the
# stompserver Ruby gem.  This is because I already have a running instance 
# of ActiveMQ.  My system is set up as follows:
#
# stompserver:: port 51613
# AMQ:: port => 61613
#
# == Software Versions
#
# This project is currently based on:
#
# stomp:: gem version 1.1
# stompserver:: gem version 0.9.9
# AMQ:: Version 5.2.0
# ruby18:: ruby 1.8.7 (2008-08-11 patchlevel 72) [i486-linux]
# ruby19:: ruby 1.9.0 (2008-06-20 revision 17482) [i486-linux]
#
# == Rdoc Generation
#
# To generate rdoc for this project, use:
#
# * rake doc:rdoc
#
# == Stompserver Start Options
#
# === stompserver Command Line Options
#
# Note: these options are for stompserver and have nothing to do with AMQ.
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
# === stompserver Configuration File Options
#
# Note: these options are for stompserver and have nothing to do with AMQ.
#
# Configuration options can also be stored in a configuration file.  This is
# normally a YAML file named <b>stompserver.conf</b> in the server's working 
# directory. An example of such a configuration file is provided in this 
# project.
#
# == Active MQ Configuration
#
# Documentation TBD.
#
# == Testing
#
# The client code in this project has been tested against:
#
# stompserver:: Version as described above
# AMQ:: Version as described above
#
# There are no formal unit tests for this project.  Feel free to clone and
# add them if you care to. :-)
#
# Before running any of the command line tests described below, you must
# have a server (stompserver or AMQ) up and running.  Furthermore, any AMQ
# server must be configured to accept the stomp message protocols.
#
# === Client To Server Connection Parameters
#
# Client to server connection parameters can best be controlled by modifying
# the <b>props.yaml</b> configuration file found in the project's root directory.
#
# === Basic Producer and Consumer Tests
#
# The basic producer (putter) and consumer (getter) clients are found in the
# <b>basic</b> subdirectory of this project.  The objective of these tests is to:
#
# * Start a basic message getter.
# * Send messages to the basic message getter.
#
# To run these tests:
#
# * Terminal 1: ruby basic/queue_get.rb
# * Terminal 1: observe output
# * Terminal 2: ruby basic/queue_put.rb
# * Terminal 2: observe output
#
# Alternate run method:
#
# * Terminal 1: rake basic:getter
# * Terminal 1: observe output
# * Terminal 2: rake basic:putter
# * Terminal 2: observe output
#
# === Queued EOF Producer and Consumer Tests
#
# The queued EOF producer (putter) and consumer (getter) clients are found 
# in the <b>queue-eof</b> subdirectory of this project.  The objective of 
# these tests is to:
#
# * Start a message getter which continuously waits for messages.
# * Ends when special EOF messsage is encountered on the input queue.
# * Send many messages to the message getter.
# * Eventually send the special EOF message.
#
# To run these tests:
#
# * Terminal 1: ruby queue-eof/queue_get.rb
# * Terminal 2: ruby queue-eof/queue_put.rb
# * Terminal 1: Observe output
# * Terminal 2: Repeat the queue_put step one or many times
# * Terminal 1: Observe output
# * Terminal 2: ruby queue-eof/queue_put.rb TRUE
# * Terminal 1: Observe output
#
# Alternate run method:
#
# * Terminal 1: rake qeof:getter
# * Terminal 2: rake qeof:putter
# * Terminal 1: Observe output
# * Terminal 2: Repeat the queue_put step one or many times
# * Terminal 1: Observe output
# * Terminal 2: rake qeof:putter_true
# * Terminal 1: Observe output
#
# === Threaded Producer and Consumer Test
#
# Show an example with the following characteristics:
#
# * A putter knows how many getters (n) will be processing messages
# * The putter evenly distributes messages across (n) queues 
# * (n) getter threads are started, and process messages
#
# To run these tests:
#
# * Terminal 1: ruby threaded/getters_demo.rb
# * Terminal 1: Observe output
#
# Alternate run method:
#
# * Terminal 1: rake threaded:getters
# * Terminal 1: Observe output
#

