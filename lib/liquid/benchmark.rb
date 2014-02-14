require 'liquid/timing'

module Benchmark
  def realtime(&block)
    timing = Timing.start
    yield
    timing.stop.to_f / 1_000_000_000
  end
end
