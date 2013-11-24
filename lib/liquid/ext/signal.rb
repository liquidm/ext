module Signal
  def self.register_shutdown_handler(&block)
    signals = %w(INT TERM)

    # The signal QUIT is in use by the JVM itself
    signals << 'QUIT' unless RUBY_PLATFORM == 'java'

    signals.each do |sig|
      old = trap(sig) {}
      trap(sig) { block.call; old.call }
    end
  end
end
