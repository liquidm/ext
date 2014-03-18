require 'liquid/logger'

class HealthCheck
  class Result
    attr_reader :message
    attr_reader :exception

    def initialize(healthy, message, exception)
      @healthy = healthy
      @message = message
      @exception = exception
    end

    def healthy?
      @healthy
    end

    def to_s
      "Result{isHealthy=#{healthy?},message=#{message.inspect},exception=#{exception.inspect}}"
    end
  end

  @@checks = {}

  def self.inherited(child)
    @@checks[child.name.demodulize] = child
  end

  def self.run
    @@checks.inject({}) do |result, (name, handler)|
      result[name] = handler.new.execute
      result
    end
  end

  def self.poll(interval = 5)
    loop do
      @healthy = run.values.all?(&:healthy?)
      sleep(interval)
    end
  end

  def self.healthy?
    @healthy.nil? ? run.values.all?(&:healthy?) : @healthy
  end

  def execute
    check
  rescue => e
    Result.new(false, "failed to execute check", e)
  end
end
