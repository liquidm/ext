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
      "Result(healthy=#{healthy?},message=#{message.inspect},exception=#{exception.inspect})"
    end
  end

  @@checks = {}
  @@callbacks = []

  def self.register(name, &block)
    @@checks[name.to_s] = block
  end

  def self.inherited(child)
    @@checks[child.name.demodulize] = child
  end

  def self.callback(cb = nil, &block)
    @@callbacks << (cb || block)
  end

  def self.run
    @@checks.inject({}) do |results, (name, handler)|
      if handler.is_a? Proc
        result = handler.call
      else
        result = handler.new.execute
      end

      unless result.is_a? Result
        result = Result.new(result , nil, nil)
      end

      results[name] = result
      results
    end
  end

  def self.poll(interval = 5)
    loop do
      sleep(interval)
      trigger
    end
  end

  def self.trigger
    results = run
    @@callbacks.each do |cb|
      begin
        cb.call(results)
      rescue => e
        $log.exception(e, "failed to run health check callback")
      end
    end
  end

  def self.healthy?
    run.values.all?(&:healthy?)
  end

  def execute
    check
  rescue => e
    Result.new(false, "failed to execute check", e)
  end
end
