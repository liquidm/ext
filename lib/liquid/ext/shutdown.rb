module Shutdown

  # Receives a time span in seconds and a block which will be registered for execution when the program exits.
  # If multiple hanlders are registered, they are executed in reverse order of registration.
  #
  # If a handler throws an exception or takes longer then the specified time span, execution skips to the next
  # handler in line.
  #
  # If the first parameter is nil, the handler will not check the codes runtime. Be cautios when executing
  # asynchronous code when the 'seconds' parameter set to nil value as blocking codes would prevent
  # the process from terminating.
  def self.with_handler_in_time(seconds, source_location = nil)
    at_exit do
      $log.info("Execute shutdown handler at #{(source_location || Proc.new.source_location).join(':')}") if $log
      begin
        Timeout::timeout(seconds) { yield }
      rescue => e
        $log.exception e if $log
      end
    end
  end


  # Receives a block which will be registered for execution when the program exits.
  # If multiple hanlders are registered, they are executed in reverse order of registration.
  #
  # with_handler will not check the execution duration of the given block so only
  # use this for non_blocking code, use with_handler_in_time if you make potentially
  # blocking calls
  def self.with_handler
    self.with_handler_in_time(nil, Proc.new.source_location ) { yield }
  end

end

