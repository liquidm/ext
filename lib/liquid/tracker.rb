if RUBY_PLATFORM == "java"
  require 'liquid/metrics'
  require 'liquid/metrics/tracker_reporter'

  module Tracker
    class Metrics
      def self.event
        (@events ||= ::Metrics.meter("tracker.events")).mark
      end
    end
  end

  Dir[File.expand_path("../tracker/*.rb", __FILE__)].each do |f|
    require f
  end
end
