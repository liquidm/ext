require 'liquid/tracker/json_serializer'

module Tracker
  class Base
    attr_accessor :serializer

    def initialize(topic)
      @serializer = JsonSerializer.new
      @topic = topic
    end
  end
end
