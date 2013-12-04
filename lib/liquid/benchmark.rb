require 'liquid/timing'

module Benchmark
  def realtime(&block)
    timing = Timing.start
    yield
    timing.stop
  end
end
