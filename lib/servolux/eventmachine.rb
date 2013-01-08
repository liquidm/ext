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

    def after_stopping
      EventMachine.stop_event_loop if EventMachine.reactor_running?
      @reactor.kill
      @reactor.join if @reactor.is_a?(Thread)
    end

    def run
      unless EventMachine.reactor_running?
        @reactor.join if @reactor.is_a?(Thread)
        @reactor = Thread.new do
          begin
            EventMachine.run { boot }
          rescue => e
            $log.exception(e)
          end
        end
      end
    end

  end
end
