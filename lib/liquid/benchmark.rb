java_import 'java.lang.System'

module Benchmark
  def realtime(&block)
    t0 = System.nano_time
    yield
    ((System.nano_time - t0).to_f / 1_000_000_000).round(3)
  end
end
