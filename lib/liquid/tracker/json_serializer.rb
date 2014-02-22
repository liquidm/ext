require 'multi_json'

module Tracker
  class JsonSerializer
    def initialize(dimensions)
      @dimensions = dimensions
    end

    def dump(obj)
      MultiJson.dump(@dimensions.merge(obj))
    end
  end
end
