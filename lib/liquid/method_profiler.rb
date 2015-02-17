require 'csv'

# Example usage:
#
# MethodProfiler.profile!(Ed::RequestContextAccumulator) { |method| method.to_s =~ /\Aadd_/ || method.to_s =~ /\Aset_/ }
# MethodProfiler.profile!(Ed::RequestContextValidator, true) { |method| method.to_s =~ /\Avalidate_/ }
#
# This will produce a csv file with some profiling output.

class MethodProfiler
  attr_reader :klass

  def self.profile! klass, report_values = false, &method_filter
    profiler = MethodProfiler.new(klass, report_values, &method_filter)
    profiler.run!
  end

  def self.get klass
    (@profilers ||= {})[klass]
  end

  def self.register klass, profiler
    (@profilers ||= {})[klass] = profiler
  end

  def running?
    @running
  end

  def run!
    return if running?
    @running = true
    Thread.new do
      Thread.name = "#{klass} Profiler"

      loop do
        sleep 60

        report_to_file!
      end
    end
  end

  def report_to_file!
    @semaphore.synchronize do
      CSV.open(File.join(ROOT, "log", "#{klass}.csv"), "wb") do |csv|
        values = value_names
        csv << (["method", "mean time", "samples"] + values.map(&:to_s))
        @methods.each do |name, stats|
          row = [name, stats.time, stats.count]
          value_names.each {|value| row.push(stats.results[value] || 0)}
          csv << row
        end
      end
    end
  end

  def initialize klass, report_values = false, &method_filter
    return if self.class.get(klass)
    self.class.register(klass, self)
    @klass = klass
    @methods = {}
    @semaphore = Mutex.new
    @report_values = report_values
    @klass.class_eval "def method_profiler; @method_profiler ||= MethodProfiler.get(#{klass}); end"
    @klass.instance_methods.each do |method|
      if method_filter.call(method)
        @klass.class_eval "alias :old_#{method} :#{method}
          def #{method} *args
            start = System.nano_time
            result = old_#{method}(*args)
            time = System.nano_time - start
            method_profiler.log(:#{method}, time, result)
            result
          end"
      end
    end
  end

  def log method_name, time, result
    @semaphore.synchronize do
      method = (@methods[method_name] ||= ProfiledMethod.new)
      method.log(time, result)
    end
  end

  def value_names
    if @report_values
      @methods.values.map {|method| method.results.keys}.flatten
    else
      []
    end
  end

  class ProfiledMethod
    attr_reader :count, :results

    def initialize
      @count = 0
      @mean_time = 0.0
      @results = {}
    end

    def log time, result
      @mean_time = (@mean_time * @count + time) / (@count + 1)
      @count += 1
      @results[result] ||= 0
      @results[result] += 1
    end

    def time
      @mean_time.to_f / 1_000_000
    end
  end
end

