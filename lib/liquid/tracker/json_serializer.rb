require 'multi_json'

module Tracker
  class JsonSerializer
    def dump(obj)
      MultiJson.dump(obj)
    end
  end
end
