# encoding: utf-8

require 'eventmachine'
require 'servolux'
require 'thread'

module Servolux
  class EventMachineServer < Server

    def initialize(name, opts = {})
      super
      EventMachine.error_handler do |e|
        $log.exception(e)
        raise e
      end
    end

    def before_starting
      @reactor = Thread.new do
        begin
          EventMachine.run { boot if respond_to?(:boot) }
        rescue => e
          $log.exception(e)
        end
      end
    end

    def after_stopping
      $log.debug("eventmachine stop")
      EventMachine.stop_event_loop if EventMachine.reactor_running?
      @reactor.kill
      @reactor.join if @reactor.is_a?(Thread)
    end

    def run
    end

  end
end
