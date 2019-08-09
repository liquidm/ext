module Tracker
  class JsonSerializer
    def initialize(dimensions)
      @dimensions = dimensions
    end

    def dump(obj)
      { dimensions: @dimensions, values: obj }
    end
  end
end
