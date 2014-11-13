module Signal
  # be cautious with this shutdown handler as it does not
  # guarantee execution of all handlers and swallows exceptions
  # inside handlers. Use Shutdown.register_with_handler instead
  def self.register_shutdown_handler(&block)
    signals = %w(INT TERM)

    # The signal QUIT is in use by the JVM itself
    signals << 'QUIT' unless RUBY_PLATFORM == 'java'

    signals.each do |sig|
      old = trap(sig) {}
      trap(sig) do
        $log.debug("shutdown", handler: block.inspect)
        block.call
        old.call
      end
    end
  end
end
