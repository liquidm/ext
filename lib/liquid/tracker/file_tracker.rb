require 'liquid/tracker/base'

module Tracker
  class FileTracker < Base

    def event(topic, data)
      file = File.open(File.join(ROOT, 'log', "tracker-#{topic}.log"), 'a')
      file.sync = true
      file.write(data)
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
