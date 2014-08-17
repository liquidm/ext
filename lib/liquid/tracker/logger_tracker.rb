require 'liquid/tracker/base'

module Tracker
  class LoggerTracker < Base
    def event(topic, data)
      $log.info("tracker:event:#{topic} #{data}")
    end

    def down?
      false
    end

    def shutdown
    end
  end
end
