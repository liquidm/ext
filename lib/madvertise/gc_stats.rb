# encoding: utf-8
require 'metriks'
require 'singleton'

class GCStats
  include Singleton

  # RUBY 1.9.X-Implementation
  module Yarv
    def enable
      GC::Profiler.enable
    end

    def clear
      GC::Profiler.clear
    end

    def gather
      count_collections
      count_allocations
      count_objects
      Metriks.timer('gc_stats.total_time').update(GC::Profiler.total_time)
    end

    def count_collections
      Metriks.histogram('gc_stats.collections').update(GC.count)
    end

    def count_allocations
      allocated_size = GC.respond_to?(:malloc_allocated_size) ? GC.malloc_allocated_size / 1000.0 : 0
      Metriks.histogram('gc_stats.allocated').update(allocated_size)
    end

    def count_objects
      objects = ObjectSpace.count_objects
      objects = objects[:TOTAL] - objects[:FREE]
      Metriks.histogram('gc_stats.objects').update(objects)
    end
  end

  if RUBY_VERSION =~ /^1\.9/
    extend Yarv
  end

  def self.available?
    respond_to?(:gather)
  end

  def self.start!
    if available?
      enable
      $log.info("gc:stats", enabled: true)

      EventMachine.next_tick do
        EventMachine::PeriodicTimer.new(60*60) do
          GC.start
        end

        EventMachine::PeriodicTimer.new(60) do
          gather
          clear
        end
      end
    else
      $log.info("gc:stats", enabled: false)
    end
  end
end
