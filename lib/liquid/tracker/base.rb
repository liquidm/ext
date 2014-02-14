require 'liquid/tracker/json_serializer'

module Tracker
  class Base
    attr_accessor :serializer

    def initialize
      @serializer = JsonSerializer.new
    end
  end
end
