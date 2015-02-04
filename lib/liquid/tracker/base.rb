require 'liquid/tracker/json_serializer'
java_import 'java.util.concurrent.ConcurrentHashMap'

module Tracker
  class Base
    attr_accessor :dimensions

    def initialize(dimensions = {})
      @dimensions = dimensions

      @topics = ConcurrentHashMap.new
      @topics_for_event = Hash.new{ |h, k| h[k] = [] }
      @event_lookup = nil
    end

    def with_topic(topic, serializer = nil)
      @topics["#{topic}#{serializer}"] ||= Topic.new(topic, self, serializer)
    end

    def dispatch(topic_events_map, serializer = nil, &event_lookup)
      @topics_for_event.reject! { true }
      @event_lookup = event_lookup

      topic_events_map.each do |topic, events|
        events.each do |event|
          $log.info("tracker:dispatch", event: event, topic: topic)
          @topics_for_event[event] << with_topic(topic.to_s, serializer)
        end
      end
    end

    def dispatch_event(event)
      event_lookup = @event_lookup.call(event)

      if (topics = @topics_for_event[event_lookup]).any?
        topics.each do |topic|
          topic.event(event)
        end
      else
        $log.warn("tracker:unregistered_event", event: event_lookup)
      end
    end
  end

  class Topic
    def initialize(topic, tracker, serializer = nil)
      @topic = topic
      @tracker = tracker
      @serializer = (serializer || JsonSerializer).new(tracker.dimensions)
    end

    def event(obj)
      log_entry = @serializer.dump(obj)
      @tracker.event(@topic, log_entry) if log_entry
    end
  end
end
