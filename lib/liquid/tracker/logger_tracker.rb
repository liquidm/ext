require 'liquid/boot'
require 'liquid/tracker/base'

module Tracker
  class LoggerTracker < Base
    def event(obj)
      $log.info("tracker:event #{@serializer.dump(obj)}")
    end

    def down?
      false
    end

    def shutdown
    end
  end
end
