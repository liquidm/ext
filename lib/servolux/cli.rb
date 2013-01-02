# encoding: utf-8

require 'madvertise/ext/environment'
require 'mixlib/cli'
require 'servolux'

module Servolux
  class BaseCLI
    include Mixlib::CLI

    def self.inherited(subclass)
      subclass.option :environment,
        :short => '-e ENVIRONMENT',
        :long => '--environment ENVIRONMENT',
        :description => "Set the daemon environment",
        :default => "development",
        :proc => ->(value) { Env.set(value) }

      subclass.option :debug,
        :short => '-D',
        :long => '--debug',
        :description => "Enable debug output",
        :boolean => true,
        :default => false

      subclass.option :help,
        :short => '-h',
        :long => '--help',
        :description => "Show this message",
        :on => :tail,
        :boolean => true,
        :show_options => true,
        :exit => 0
    end

    def self.parse_options
      new.tap do |cli|
        cli.parse_options
      end.config
    end
  end

  class CLI < BaseCLI
  end

  class DaemonCLI < BaseCLI
    option :name,
      :short => '-n NAME',
      :long => '--name NAME',
      :description => 'Process name',
      :default => $0,
      :proc => ->(value) { $0 = value }

    option :pidfile,
      :short => '-p PIDFILE',
      :long => '--pidfile PIDFILE',
      :description => "The daemon pidfile",
      :default => "#{$0}.pid"

    option :daemonize,
      :short => '-d',
      :long => '--daemonize',
      :description => "Daemonize the server process",
      :boolean => true,
      :default => false

    option :kill,
      :short => '-k',
      :long => '--kill',
      :description => "Kill the currently running daemon instance",
      :boolean => true
  end
end
