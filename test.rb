require 'bundler/setup'
require 'liquid/boot'
require 'liquid/health_checks'

java_import 'com.codahale.metrics.health.HealthCheck'

class TestCheck < HealthCheck
  def check
    Result.unhealthy
  end
end

HealthChecks.register("test", TestCheck.new)
results = HealthChecks.run

results.each do |name, result|
  puts "#{name}: #{result.healthy? ? "OK" : "FAIL"}"
end

healthy = results.values.all?(&:healthy?)
exit healthy ? 0 : 2
