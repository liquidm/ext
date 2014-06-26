require 'liquid/tracker/json_serializer'

module Tracker
  class Base
    attr_accessor :dimensions

    def initialize(dimensions = {})
      @dimensions = dimensions
    end

    def with_topic(topic, serializer = nil)
      Topic.new(topic, self, serializer)
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
