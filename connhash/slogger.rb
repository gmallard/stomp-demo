=begin

Example STOMP call back logger class.

Optional callback methods:

    on_connecting: connection starting
    on_connected: successful connect
    on_connectfail: unsuccessful connect (will usually be retried)
    on_disconnect: successful disconnect

    on_miscerr: on miscellaneous xmit/recv errors

All methods are optional, at the user's requirements.

If a method is not provided, it is not called (of course.)

IMPORTANT NOTE:  call back logging methods *MUST* not raise exceptions, 
otherwise the underlying STOMP connection will fail in mysterious ways.

Callback parameters: are a copy of the @parameters instance variable for
the Stomp::Connection.

=end

require 'logger'	# use the standard Ruby logger .....

class Slogger
  #
  def initialize(init_parms = nil)
    @log = Logger::new(STDOUT)		# User preference
    @log.level = Logger::DEBUG		# User preference
    @log.info("Logger initialization complete.")
  end

  # Log connecting events
  def on_connecting(parms)
    begin
      @log.debug "Connecting: #{info(parms)}"
    rescue
      @log.debug "Connecting oops"
    end
  end

  # Log connected events
  def on_connected(parms)
    begin
      @log.debug "Connected: #{info(parms)}"
    rescue
      @log.debug "Connected oops"
    end
  end

  # Log connectfail events
  def on_connectfail(parms)
    begin
      @log.debug "Connect Fail #{info(parms)}"
    rescue
      @log.debug "Connect Fail oops"
    end
  end

  # Log disconnect events
  def on_disconnect(parms)
    begin
      @log.debug "Disconnected #{info(parms)}"
    rescue
      @log.debug "Disconnected oops"
    end
  end


  # Log miscellaneous errors
  def on_miscerr(parms, errstr)
    begin
      @log.debug "Miscellaneous Error #{info(parms)}"
      @log.debug "Miscellaneous Error String #{errstr}"
    rescue
      @log.debug "Miscellaneous Error oops"
    end
  end

  private

  def info(parms)
    #
    # Available in the Hash:
    # parms[:cur_host]
    # parms[:cur_port]
    # parms[:cur_login]
    # parms[:cur_passcode]
    # parms[:cur_ssl]
    # parms[:cur_recondelay]
    # parms[:cur_parseto]
    # parms[:cur_conattempts]
    #
    "Host: #{parms[:cur_host]}, Port: #{parms[:cur_port]}, Login: Port: #{parms[:cur_login]}, Passcode: #{parms[:cur_passcode]}" 
  end
end # of class

