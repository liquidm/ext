require 'singleton'

java_import 'com.codahale.metrics.HealthCheckRegistry'

class HealthChecks
  include Singleton

  attr_reader :registry

  def initialize
    @registry = HealthCheckRegistry.new
  end

  def self.register(name, handler)
    instance.registry.register(name, handler)
  end

end
