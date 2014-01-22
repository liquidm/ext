java_import 'java.lang.System'

module Timing
  def self.start
    TimingContext.new
  end

  class TimingContext
    def initialize
      reset!
    end

    def reset!
      @start = @last_tick = System.nano_time
    end

    def tick
      rt = runtime_since(@last_tick)
      @last_tick = System.nano_time
      rt
    end

    def stop
      rt = runtime_since(@start)
      reset!
      rt
    end

    private

    def runtime_since(start)
      rt = System.nano_time - start
      rt = rt.to_f / 1_000_000_000
      rt
    end

  end
end
