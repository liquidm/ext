require 'liquid/metrics/reporter'
require 'liquid/tracker'

module Metrics
  class TrackerReporter < Reporter

    def initialize(registry, tracker, params = {})
      super(registry, params)
      @tracker = tracker
    end

    def report_gauge(name, gauge)
      @tracker.event(super)
    end

    def report_counter(name, counter)
      @tracker.event(super)
    end

    def report_histogram(name, histogram)
      @tracker.event(super)
    end

    def report_meter(name, meter)
      @tracker.event(super)
    end

    def report_timer(name, timer)
      @tracker.event(super)
    end

  end
end
