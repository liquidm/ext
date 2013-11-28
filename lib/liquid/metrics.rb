require 'singleton'

java_import 'com.codahale.metrics.MetricRegistry'
java_import 'com.codahale.metrics.JmxReporter'

require 'liquid/metrics/logger_reporter'

class Metrics
  include Singleton

  attr_reader :registry

  def initialize
    @registry = MetricRegistry.new
    JmxReporter.forRegistry(@registry).build.start
    # TODO: only for testing
    LoggerReporter.new(@registry).start
  end

  def self.registry
    instance.registry
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
