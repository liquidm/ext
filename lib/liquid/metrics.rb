require 'singleton'

java_import 'com.codahale.metrics.MetricRegistry'
java_import 'com.codahale.metrics.JmxReporter'

require 'liquid/metrics/logger_reporter'

module Metrics

  @@registry = MetricRegistry.new

  def self.start
    reporters = [
      JmxReporter.forRegistry(@@registry).build,
      LoggerReporter.new(@@registry),
    ]
    reporters.each(&:start)
    Signal.register_shutdown_handler { reporters.each(&:stop) }
  end

  def self.registry
    @@registry
  end

  def self.counter(name)
    registry.counter(name)
  end

  def self.meter(name)
    registry.meter(name)
  end

  def self.histogram(name)
    registry.histogram(name)
  end

  def self.timer(name)
    registry.timer(name)
  end
end
