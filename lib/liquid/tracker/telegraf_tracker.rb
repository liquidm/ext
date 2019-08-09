require 'liquid/tracker/base'
require 'telegraf'

module Tracker
  class TelegrafTracker < Base

    def initialize(port, dimensions = {}, serializer = nil)
      super(dimensions, serializer)
      @telegraf = Telegraf::Agent.new("udp://localhost:#{port}") rescue nil
    end

    def event(topic, data)
      data[:values].each do |k, v|
        data[:values][k] = v.to_s if v.is_a?(Symbol)
      end

      @telegraf.write!(data[:values].delete(:name), tags: data[:dimensions], values: data[:values])
    end

    def down?
      !!@telegraf
    end

    def shutdown
    end
  end
end
