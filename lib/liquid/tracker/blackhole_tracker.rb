require 'liquid/tracker/base'

module Tracker
  class BlackholeTracker < Base
    def event(topic, data)
    end

    def down?
      false
    end

    def shutdown
    end
  end
end
