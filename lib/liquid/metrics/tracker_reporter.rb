require 'liquid/metrics/reporter'

module Metrics
  class TrackerReporter < Reporter

    def initialize(tracker)
      super
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
