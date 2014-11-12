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
  def self.register_handler_with_timeout(seconds, &source_location)
    return unless block_given?
    at_exit do
      $log.info("shutdown", location: source_location.inspect) if $log
      begin
        Timeout::timeout(seconds, &source_location)
      rescue => e
        $log.exception e if $log
      end
    end
  end


  # Receives a block which will be registered for execution when the program exits.
  # If multiple hanlders are registered, they are executed in reverse order of registration.
  #
  # with_handler will not check the execution duration of the given block so only
  # use this for non_blocking code, use register_handler_with_timout if you make potentially
  # blocking calls
  def self.register_handler(&source_location)
    return unless block_given?
    self.register_handler_with_timeout(nil, &source_location)
  end

end

