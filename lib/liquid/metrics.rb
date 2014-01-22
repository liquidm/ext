require 'singleton'

java_import 'com.codahale.metrics.MetricRegistry'
java_import 'com.codahale.metrics.JmxReporter'

require 'liquid/metrics/logger_reporter'

class Metrics
  include Singleton

  attr_reader :registry

  def initialize
    @registry = MetricRegistry.new
    @reporters = [
      JmxReporter.forRegistry(@registry).build,
      LoggerReporter.new(@registry),
    ]
    @reporters.each(&:start)
    Signal.register_shutdown_handler { @reporters.each(&:stop) }
  end

  def counter(name)
    registry.counter(name)
  end

  def meter(name)
    registry.meter(name)
  end

  def histogram(name)
    registry.histogram(name)
  end

  def timer(name)
    registry.timer(name)
  end
end
