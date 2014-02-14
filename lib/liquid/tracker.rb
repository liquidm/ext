require 'liquid/metrics'

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
