require 'liquid/logger'

require_relative './metrics-healthchecks-3.0.1.jar'
java_import 'com.codahale.metrics.health.HealthCheckRegistry'

class HealthChecks
  @registry = HealthCheckRegistry.new

  def self.registry
    @registry
  end

  def self.register(name, handler)
    registry.register(name, handler)
  end

  def self.run
    registry.run_health_checks
  end
end
