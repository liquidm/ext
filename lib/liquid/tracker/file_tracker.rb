require 'liquid/tracker/base'

module Tracker
  class FileTracker < Base

    def event(obj)
      file = File.open(File.join(ROOT, 'tmp', 'tracker.log'), 'a')
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
