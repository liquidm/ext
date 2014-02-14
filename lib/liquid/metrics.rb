require 'liquid/logger'

require_relative './metrics-core-3.0.1.jar'
java_import 'com.codahale.metrics.Histogram'
java_import 'com.codahale.metrics.JmxReporter'
java_import 'com.codahale.metrics.MetricRegistry'
java_import 'java.util.concurrent.TimeUnit'

class Histogram
  java_alias :update_long, :update, [Java::long]
end

module Metrics
  @registry = MetricRegistry.new
  @reporters = []

  def self.start(period = nil, unit = nil)
    @period ||= 10
    @unit ||= TimeUnit::SECONDS
    register_reporter(JmxReporter.forRegistry(@registry).build)
    Signal.register_shutdown_handler { stop }
  end

  def self.stop
    @reporters.each do |reporter|
      reporter.run if reporter.respond_to?(:run)
      reporter.stop
    end
    @reporters.clear
  end

  def self.register_reporter(reporter)
    reporter.start(@period, @unit)
    @reporters << reporter
  end

  def self.registry
    @registry
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
