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
      rt = System.nano_time - @last_tick
      @last_tick = System.nano_time
      rt
    end

    def stop
      rt = System.nano_time - @start
      reset!
      rt
    end

  end
end
