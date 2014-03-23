require 'liquid/tracker/base'

module Tracker
  class KafkaTracker < Base

    java_import 'kafka.javaapi.producer.Producer'
    java_import 'kafka.producer.ProducerConfig'
    java_import 'kafka.producer.KeyedMessage'

    def initialize(properties, dimensions = {})
      super(dimensions)
      @producer = Producer.new(ProducerConfig.new(properties))
    end

    def down?
      # TODO: async is fire and forget. we might want to handle
      # QueueFullExceptions later
      false
    end

    def event(topic, data)
      @producer.send(KeyedMessage.new(topic, data))
    rescue => e
      # TODO: maybe fall back to FileTracker here
      $log.exception(e, "failed to log event=#{obj.inspect}")
    end

    def shutdown
      @producer.close if @producer
    rescue Java::KafkaProducer::ProducerClosedException
      # pass
    end

  end
end
