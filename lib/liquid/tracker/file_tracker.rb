require 'liquid/tracker/base'

module Tracker
  class FileTracker < Base

    def event(obj, topic)
      file = File.open(File.join(ROOT, 'log', "tracker-#{topic}.log"), 'a')
      file.sync = true
      file.write(@serializer.dump(obj))
      file.write("\n")
      file.close
    end

    def down?
      false
    end

    def shutdown
    end
  end
end
