require 'liquid/boot'
require 'liquid/tracker/base'

module Tracker
  class LoggerTracker < Base
    def event(obj, topic)
      $log.info("tracker:event:#{topic} #{@serializer.dump(obj)}")
    end

    def down?
      false
    end

    def shutdown
    end
  end
end
