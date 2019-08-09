if RUBY_PLATFORM == "java"
  require 'liquid/metrics'
  require 'liquid/tracker'

  module Liquid
    class Server
      attr_reader :started_at

      def name
        @name ||= self.class.name.downcase.gsub(/::/, '.')
      end

      def initialize
        @started_at = Time.now
        $log.info("#{name} #{RUBY_DESCRIPTION}")
        $log.info("#{name}", env: Env.mode)
        Signal.register_shutdown_handler { System.exit(0) }
        Signal.register_shutdown_handler { ZContext.destroy }
        initialize_raven
        initialize_trackers
        initialize_metrics
        initialize_health_checks
      end

      def initialize_raven
        return unless $conf.raven
        require 'raven'
        Raven.configure do |config|
          config.dsn = $conf.raven.dsn
          config.logger = $log
        end
        $log.add_exception_handler do |exc, message, attribs|
          Raven.capture_exception(exc)
        end
      end

      def initialize_trackers
        @trackers = []

        if $conf.tracker.kafka.enabled
          # http://kafka.apache.org/documentation.html#newproducerconfigs
          properties = java.util.Properties.new
          properties['bootstrap.servers'] = $conf.tracker.kafka.brokers.join(',')
          properties['key.serializer'] = 'org.apache.kafka.common.serialization.StringSerializer'
          properties['value.serializer'] = 'org.apache.kafka.common.serialization.StringSerializer'
          properties['linger.ms'] = 10

          if ['gzip', 'snappy'].include? $conf.tracker.kafka.compression
            properties['compression.type'] = $conf.tracker.kafka.compression
          end

          trackers << ::Tracker::KafkaTracker.new(properties, $conf.tracker.dimensions)
        end

        if $conf.tracker.telegraf.enabled
          trackers << ::Tracker::TelegrafTracker.new($conf.tracker.dimensions)
        end

        if @trackers.none?
          trackers << ::Tracker::LoggerTracker.new($conf.tracker.dimensions)
        end

        @trackers.each do |tracker|
          Signal.register_shutdown_handler { tracker.shutdown }
        end
      end

      class HealthGauge
        include Gauge

        def getValue
          HealthCheck.healthy? ? 1 : 0
        end
      end

      class UptimeGauge
        include Gauge

        def initialize(server)
          @server = server
        end

        def getValue
          @server.uptime.to_i
        end
      end

      class UsedMemoryGauge
        include Gauge

        def getValue
          runtime = Java::JavaLang::Runtime.get_runtime
          (runtime.max_memory - runtime.free_memory) / 1024 / 1024
        end
      end

      def initialize_metrics
        ::Metrics.start
        ::Metrics.gauge("#{name}.healthy", HealthGauge.new)
        ::Metrics.gauge("#{name}.uptime", UptimeGauge.new(self))
        ::Metrics.gauge("#{name}.used_memory", UsedMemoryGauge.new)
        Signal.register_shutdown_handler { ::Metrics.stop }

        @trackers.each do |tracker|
          ::Metrics::TrackerReporter.new(tracker.with_topic('metrics'))
        end
      end

      def initialize_health_checks
        Thread.new do
          Thread.name = "Health Check"
          HealthCheck.poll
        end
      end

      def initialize_zmachine
        require 'zmachine'
        ZMachine.logger = $log
        ZMachine.debug = true if $conf.zmachine.debug
        ZMachine.heartbeat_interval = 0.1
        Signal.register_shutdown_handler { ZMachine.stop }
      end

      def run
        # by default wait for all workers
        Thread.join
      end

      def uptime
        Time.now - @started_at
      end

    end
  end
end
