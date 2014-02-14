require 'liquid/metrics/reporter'

module Metrics
  class LoggerReporter < Reporter

    def initialize(registry, logger)
      super(registry)
      @logger = logger
      @marker = "metrics:"
    end

    def report_gauge(name, gauge)
      @logger.info(@marker, super)
    end

    def report_counter(name, counter)
      @logger.info(@marker, super)
    end

    def report_histogram(name, histogram)
      @logger.info(@marker, super)
    end

    def report_meter(name, meter)
      @logger.info(@marker, super)
    end

    def report_timer(name, timer)
      @logger.info(@marker, super)
    end

  end
end
