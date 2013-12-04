java_import 'java.lang.System' if RUBY_PLATFORM == 'java'

module Timing
  def self.start
    TimingContext.new
  end

  class TimingContext
    def initialize
      @jruby = RUBY_PLATFORM == 'java'
      reset!
    end

    def reset!
      @start = @last_tick = now
    end

    def tick
      rt = runtime_since(@last_tick)
      @last_tick = now
      rt
    end

    def stop
      rt = runtime_since(@start)
      reset!
      rt
    end

    private

    def now
      return System.nano_time if @jruby
      return Time.now.to_f
    end

    def runtime_since(start)
      rt = now - start
      rt = rt.to_f / 1_000_000_000 if @jruby
      rt
    end

  end
end
