require 'liquid/tracker/json_serializer'

module Tracker
  class Base
    attr_accessor :serializer

    def initialize(dimensions = {})
      @serializer = JsonSerializer.new(dimensions)
    end

    def with_topic(topic)
      Topic.new(topic, self)
    end
  end

  class Topic
    def initialize(topic, tracker)
      @topic = topic
      @tracker = tracker
    end

    def event(obj)
      @tracker.event(obj, @topic)
    end
  end
end
