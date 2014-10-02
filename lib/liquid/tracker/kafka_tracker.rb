require 'liquid/tracker/base'

module Tracker
  class KafkaTracker < Base

    java_import 'kafka.javaapi.producer.Producer'
    java_import 'kafka.producer.ProducerConfig'
    java_import 'kafka.producer.KeyedMessage'

    def initialize(properties, dimensions = {})
      @properties = properties
      super(dimensions)
    end

    def down?
      # TODO: async is fire and forget. we might want to handle
      # QueueFullExceptions later
      false
    end

    def get_thread_producer
      Thread.current[:producer] ||= Producer.new(ProducerConfig.new(@properties))
      @producer = Thread.current[:producer]
    end

    def event(topic, data)
      get_thread_producer
      require "ruby-debug"
          debugger
      @producer.send(KeyedMessage.new(topic, data))
    rescue => e
      # TODO: maybe fall back to FileTracker here
      $log.exception(e, "failed to log #{topic}=#{data.inspect}")
    end

    def shutdown
      @producer.close if @producer
    rescue Java::KafkaProducer::ProducerClosedException
      # pass
    end

  end
end
