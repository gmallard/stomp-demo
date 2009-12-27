#
# = Stomp Messaging Client Examples
#
# == Notes
#
#
# Initial examples were based on the code suplied with the stompserver gem,
# and with tests from the stomp gem.  This has been expanded as described
# subsequently.
#
# The default configuration in this project uses a non-default port for the
# stompserver Ruby gem.  This is because I already have a running instance 
# of ActiveMQ.  My system is set up as follows:
#
# stompserver:: port => 51613
# AMQ:: port => 61613
#
# === stomp Message Protocol
#
# Documentation of the stomp message protocol can be found here:
#
# * http://stomp.codehaus.org/Specification
#
# == Software Versions
#
# This project is currently based on:
#
# stomp:: gem version 1.1
# stompserver:: gem version 0.9.9 and local modifications for ruby 1.9.x compatability
# AMQ:: Version 5.2 and/or Version 5.3
#
# Client code (the getters and putters) testing has been completed 
# successfully under:
#
# ruby18:: ruby 1.8.7 (2008-08-11 patchlevel 72) [i486-linux]
# ruby19:: ruby 1.9.0 (2008-06-20 revision 17482) [i486-linux]
# ruby191:: ruby 1.9.1p243 (2009-07-16 revision 24175) [i486-linux]
#
# === stompserver Note
#
# This code was tested with the stompserver running under Ruby:
#
# * 1.9.0
# * 1.9.1
#
# The standard 0.9.9 stompserver gem using ruby
# 1.9.x fails.
#
# --------
#
# A version of server code modified for 1.9.0 and 1.9.1  is 
# available by:
#
# *	git clone git://github.com/gmallard/stompserver.git
#
# Note!: the 'master' branch of that repository also includes modifications to:
#
# * active record support for MySql
# * additions for using standard ruby 'logger' style logging
# * a variety of other enhancements to the stompserver code base
#
# To obtain a _minimal_ set of server changes for 1.9.x, see the 'minimal_19x'
# branch in that repository.
#
# === stomp Gem Note
#
# No rdoc documentation was produced during the standard install of the 0.9.9
# gem.  It is not clear why this happened.  I uninstalled the gem, and 
# reinstalled with the '--rdoc --ri' options, and all was well.
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
# Command line options for the stompserver 0.9.9 level are:
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
# Active MQ requires the following addition to the standard <b>activemq.xml</b>
# file in order to support the stomp protocol:
#
#  <!-- The transport connectors ActiveMQ will listen to -->
#  <transportConnectors>
#      .....
#   <transportConnector name="stomp" uri="stomp://localhost:61613"/>
#      .....
#  </transportConnectors>
#
# == Testing
#
# The client code in this project has been tested against:
#
# stompserver:: Versions as described above
# AMQ:: Versions as described above
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
# Also note that command line parameter overrides are allowed, see below.
# <b>However</b> the rake tests described here do <b>not</b> currently 
# support parameter overrides from the command line. <b>Beware!</b>
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
# * Terminal 1: Observe output
# * Terminal 2: ruby basic/queue_put.rb
# * Terminal 2: Observe output
#
# Alternate run method:
#
# * Terminal 1: rake basic:getter
# * Terminal 1: Observe output
# * Terminal 2: rake basic:putter
# * Terminal 2: Observe output
#
# === Queued EOF Producer and Consumer Tests
#
# The queued EOF producer (putter) and consumer (getter) clients are found 
# in the <b>queue-eof</b> subdirectory of this project.  The objective of 
# these tests is to:
#
# * Start a message getter which continuously waits for messages.
# * Ends when a special EOF messsage is encountered on the input queue.
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
# Note: when TRUE is passed to the message putter, it _must_ be the first
# command line parameter passed.  Any command line parameter overrides 
# should be coded later.
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
# === Single Producer and Threaded Consumer Test
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
# === stomp Monitor Demonstration
#
# Show an example of a stomp server monitor, as described in the stompserver
# rdoc's.
#
# To run this demonstration:
#
# * Terminal 1: ruby monitor/stompmon.rb
# * Terminal X: Run individual putter tests to place messages on queues
# * Terminal 1: Observe queue statistics updates every five seconds
#
# Alternate run method:
#
# * Terminal 1: rake monitor:monitor
# * Terminal X: Run individual putter tests to place messages on queues
# * Terminal 1: Observe queue statistics updates every five seconds
#
# ==== Note
#
# This demonstration is stompserver specific.  It should run on Active MQ,
# but will display nothing of interest (this is untested).
#
# === stomp Connection Object Demonstration
#
# Show an example of using a stomp +connection+ object to send and 
# receive messages synchronously.
#
# To run this demonstration:
#
# * Terminal 1: ruby connection/send_recv.rb
# * Terminal 1: Observe output
#
# Alternate run method:
#
# Terminal 1: rake conn:sendreceive
# * Terminal 1: Observe output
#
# === Utilities
#
# Provide utilities for working with the code in this project.
#
# ==== Clear Queue
#
# This utility can be used to drain / clear a queue of all messages.
#
# To run the clear queue utility:
#
# * ruby utils/clearq.rb "/queue/qname"
#
# The +full+ name of the queue to clear +must+ be provided as the first 
# command line argument.
#
# == Overriding Parameters in the Configuration File
#
# Command line parameters can override those specified in the <b>props.yaml</b>
# configuration file.  A summary of the command line overrides allowed is 
# shown here:
#
# -u userid::
#     The user id to connect to the server with.
# --user=userid::
#     Same as -u.
# -p password::
#     The server password to use.
# --password=password::
#     Same as -p.
# -s servername::
#     The server name to connect to.  An IP address may be used.
# --server=servername::
#     Same as -s.
# -P portnumber::
#     The port the server is serving from.
# --port=portnumber::
#     Same as -P.
# -h::
#     Get help on the command line options, and exit.
# --help::
#     Same as -h.
#
# == Environment Parameter Overrides
#
# The ability to override:
#
# * queue names for putters and getters
# * putter message counts
#
# is provided.  A simple example of using this is:
#
# * MAX_MSGS=100 QNAME="/queue/special" ruby basic/queue_put.rb
#
# Again, this capability is _not_ provided for in the rake executions of the examples.
#
# == Eventmachine Examples
#
# Several examples of using the ruby eventmachine gem's stomp support have 
# been added.
#

