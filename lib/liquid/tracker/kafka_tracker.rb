require 'liquid/tracker/base'

require_relative '../scala-library-2.10.3.jar'
require_relative '../metrics-core-2.2.0.jar'
require_relative '../metrics-annotation-2.2.0.jar'
require_relative '../kafka_2.10-0.8.0.jar'

module Tracker
  class KafkaTracker < Base

    java_import 'kafka.javaapi.producer.Producer'
    java_import 'kafka.producer.ProducerConfig'
    java_import 'kafka.producer.KeyedMessage'

    def initialize(topic, brokers = "localhost:9092")
      super
      # http://kafka.apache.org/documentation.html#producerconfigs
      properties = java.util.Properties.new
      properties['metadata.broker.list'] = [brokers].flatten.join(',')
      properties['producer.type'] = 'async'
      properties['compression.codec'] = 'snappy'
      properties['serializer.class'] = 'kafka.serializer.StringEncoder'
      properties['queue.enqueue.timeout.ms'] = '0' # drop instant if q is full
      properties['queue.buffering.max.messages'] = '100000'
      properties['batch.num.messages'] = '2000'
      properties['queue.buffering.max.ms'] = '10000'
      @producer = Producer.new(ProducerConfig.new(properties))
      @topic = topic
    end

    def down?
      # TODO: async is fire and forget. we might want to handle
      # QueueFullExceptions later
      false
    end

    def event(obj)
      @producer.send(KeyedMessage.new(@topic, @serializer.dump(obj)))
    rescue => e
      # TODO: maybe fall back to file logger here
      $log.exception(e, "failed to log event=#{obj.inspect}")
    end

    def shutdown
      @producer.close if @producer
    end

  end
end
