require 'liquid/metrics'

java_import 'com.codahale.metrics.MetricFilter'
java_import 'java.util.concurrent.Executors'
java_import 'java.util.concurrent.TimeUnit'

module Metrics
  class Reporter

    attr_accessor :filter
    attr_accessor :rate_unit
    attr_accessor :duration_unit

    def initialize(registry, params = {})
      @registry = registry
      @params = params
      @filter = MetricFilter::ALL
      @executor = Executors.newSingleThreadScheduledExecutor
      self.rate_unit = TimeUnit::SECONDS
      self.duration_unit = TimeUnit::MILLISECONDS
      ::Metrics.register_reporter(self)
    end

    def rate_unit=(value)
      @rate_unit = value
      @rate_factor = value.to_seconds(1)
    end

    def duration_unit=(value)
      @duration_unit = value
      @duration_factor = 1.0 / value.to_nanos(1)
    end

    def run
      report_gauges
      report_counters
      report_histograms
      report_meters
      report_timers
    rescue => e
      $log.exception(e)
    end

    def start(period, unit)
      @executor.scheduleAtFixedRate(self, period, period, unit)
    end

    def stop
      @executor.shutdown
      @executor.awaitTermination(1, TimeUnit::SECONDS) rescue nil
    end

    def report_gauges
      @registry.gauges.each do |name, gauge|
        report_gauge(name, gauge)
      end
    end

    def report_counters
      @registry.counters.each do |name, counter|
        report_counter(name, counter)
      end
    end

    def report_histograms
      @registry.histograms.each do |name, histogram|
        report_histogram(name, histogram)
      end
    end

    def report_meters
      @registry.meters.each do |name, meter|
        report_meter(name, meter)
      end
    end

    def report_timers
      @registry.timers.each do |name, timer|
        report_timer(name, timer)
      end
    end

    def report_gauge(name, gauge)
      @params.merge({
        timestamp: Time.now.to_f,
        type: :gauge,
        name: name,
        value: gauge.value,
      })
    end

    def report_counter(name, counter)
      @params.merge({
        timestamp: Time.now.to_f,
        type: :counter,
        name: name,
        count: counter.count,
      })
    end

    def report_histogram(name, histogram)
      snapshot = histogram.snapshot
      @params.merge({
        timestamp: Time.now.to_f,
        type: :histogram,
        name: name,
        count: histogram.count,
        min: snapshot.getMin,
        max: snapshot.getMax,
        mean: snapshot.getMean,
        stdev: snapshot.getStdDev,
        median: snapshot.getMedian,
        p75: snapshot.get75thPercentile,
        p95: snapshot.get95thPercentile,
        p98: snapshot.get98thPercentile,
        p99: snapshot.get99thPercentile,
        p999: snapshot.get999thPercentile,
      })
    end

    def report_meter(name, meter)
      @params.merge({
        timestamp: Time.now.to_f,
        type: :meter,
        name: name,
        count: meter.count,
        mean_rate: convert_rate(meter.getMeanRate),
        m1: convert_rate(meter.getOneMinuteRate),
        m5: convert_rate(meter.getFiveMinuteRate),
        m15: convert_rate(meter.getFifteenMinuteRate),
      })
    end

    def report_timer(name, timer)
      snapshot = timer.snapshot
      @params.merge({
        timestamp: Time.now.to_f,
        type: :timer,
        name: name,
        min: convert_duration(snapshot.getMin),
        max: convert_duration(snapshot.getMax),
        mean: convert_duration(snapshot.getMean),
        stdev: convert_duration(snapshot.getStdDev),
        median: convert_duration(snapshot.getMedian),
        p75: convert_duration(snapshot.get75thPercentile),
        p95: convert_duration(snapshot.get95thPercentile),
        p98: convert_duration(snapshot.get98thPercentile),
        p99: convert_duration(snapshot.get99thPercentile),
        p999: convert_duration(snapshot.get999thPercentile),
        mean_rate: convert_rate(timer.getMeanRate),
        m1: convert_rate(timer.getOneMinuteRate),
        m5: convert_rate(timer.getFiveMinuteRate),
        m15: convert_rate(timer.getFifteenMinuteRate),
      })
    end

    def convert_duration(duration)
      (duration * @duration_factor).round(3)
    end

    def convert_rate(rate)
      (rate * @rate_factor).round(3)
    end

  end
end
