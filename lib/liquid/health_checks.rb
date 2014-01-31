require 'singleton'

java_import 'com.codahale.metrics.health.HealthCheckRegistry'

class HealthChecks
  include Singleton

  attr_reader :registry

  def initialize
    @registry = HealthCheckRegistry.new
  end

  def self.registry
    instance.registry
  end

  def self.register(name, handler)
    registry.register(name, handler)
  end

  def self.run
    registry.run_health_checks
  end

end
