module Shutdown

  def self.with_handler_in_time(seconds, source_location = nil)
    at_exit do
      $log.info("Execute shutdown handler at #{(source_location || Proc.new.source_location).join(':')}") if $log
      begin
        Timeout::timeout(seconds) { yield }
      rescue => e
        $log.exception e
      end
    end
  end

  def self.with_handler
    self.with_handler_in_time(nil, Proc.new.source_location ) { yield }
  end

end

