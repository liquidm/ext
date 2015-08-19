require 'liquid/tracker/base'

module Tracker
  class KafkaTracker < Base

    java_import 'org.apache.kafka.clients.producer.KafkaProducer'
    java_import 'org.apache.kafka.clients.producer.ProducerRecord'

    def initialize(properties, dimensions = {})
      super(dimensions)
      @producer = KafkaProducer.new(properties)
    end

    def down?
      # TODO: async is fire and forget. we might want to handle
      # QueueFullExceptions later
      false
    end

    def event(topic, data)
      @producer.send(ProducerRecord.new(topic, data))
    rescue => e
      # TODO: maybe fall back to FileTracker here
      $log.exception(e, "failed to log #{topic}=#{data.inspect}")
    end

    def shutdown
      @producer.close if @producer
    end

  end
end
