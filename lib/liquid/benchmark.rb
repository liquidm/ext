require 'liquid/timing'

module Benchmark
  def realtime(&block)
    timing = Timing.start
    yield
    timing.runtime
  end
end
