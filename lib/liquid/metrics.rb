require 'singleton'

java_import 'com.codahale.metrics.Histogram'
java_import 'com.codahale.metrics.MetricRegistry'
java_import 'com.codahale.metrics.JmxReporter'

require 'liquid/metrics/logger_reporter'

class Histogram
  java_alias :update_long, :update, [Java::long]
end

module Metrics

  @@registry = MetricRegistry.new
  @@reporters = []

  def self.start
    @@reporters << JmxReporter.forRegistry(@@registry).build
    @@reporters << LoggerReporter.new(@@registry)

    @@reporters.each(&:start)
    Signal.register_shutdown_handler { self.stop }
  end

  def self.stop
    @@reporters.each do |reporter|
      if reporter.respond_to?(:run)
        reporter.run
      end

      reporter.stop
    end

    @@reporters.clear
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
