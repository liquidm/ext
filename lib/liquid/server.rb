require 'liquid/metrics'
require 'liquid/tracker'

module Liquid
  class Server
    def initialize
      $log.info("#{self.class.name.downcase} #{RUBY_DESCRIPTION}")
      $log.info("#{self.class.name.downcase}", env: Env.mode)
      initialize_tracker
      initialize_metrics
    end

    def initialize_tracker
      if $conf.tracker.kafka.enabled
        # http://kafka.apache.org/documentation.html#producerconfigs
        properties = java.util.Properties.new
        properties['metadata.broker.list'] = $conf.tracker.kafka.brokers.join(',')
        properties['producer.type'] = 'async'
        properties['serializer.class'] = 'kafka.serializer.StringEncoder'
        $tracker = ::Tracker::KafkaTracker.new(properties, $conf.tracker.dimensions)
      else
        $tracker = ::Tracker::LoggerTracker.new($conf.tracker.dimensions)
      end
      Signal.register_shutdown_handler { $tracker.shutdown }
    end

    def initialize_metrics
      ::Metrics.start
      ::Metrics::TrackerReporter.new($tracker.with_topic('metrics'))
      Signal.register_shutdown_handler { ::Metrics.stop }
    end

    def initialize_zmachine
      ZMachine.logger = $log
      ZMachine.debug = true if $conf.zmachine.debug
      ZMachine.heartbeat_interval = 0.1
      Signal.register_shutdown_handler { ZMachine.stop }
    end

    def run
      # by default wait for all workers
      Thread.join
    end

  end
end
