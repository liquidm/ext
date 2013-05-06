# encoding: utf-8

require 'madvertise/boot'
require 'mixlib/cli'

$0 = File.basename($0)

class CLI
  include Mixlib::CLI

  # TODO: add config and mixin path

  option :configfile,
    short: '-c FILE',
    long: '--config FILE',
    description: 'Configuration File to load'

  option :name,
    :short => '-n NAME',
    :long => '--name NAME',
    :description => 'Process name',
    :default => $0,
    :proc => ->(value) { $0 = value }

  option :environment,
    :short => '-e ENVIRONMENT',
    :long => '--environment ENVIRONMENT',
    :description => "Set the daemon environment",
    :default => "development",
    :proc => ->(value) { Env.set(value) }

  option :debug,
    :short => '-D',
    :long => '--debug',
    :description => "Enable debug output",
    :boolean => true,
    :default => false,
    :proc => ->(value) { $conf.mixin(log_level: :debug) }

  option :help,
    :short => '-h',
    :long => '--help',
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0

  def option(name, args)
    args[:on] ||= :on
    args[:boolean] ||= false
    args[:required] ||= false
    args[:proc] ||= nil
    args[:show_options] ||= false
    args[:exit] ||= nil

    if args.has_key?(:default)
      config[name.to_sym] = args[:default]
    end

    options[name.to_sym] = args
  end

  def self.for(cls, &block)
    cli = new
    cli.instance_eval(&block) if block_given?
    cli.parse_options

    $log.info("cli:initialize", cli.config)
    $conf.reload!

    opts = cli.config.merge({
      interval: 1,
      logger: $log,
    })

    cls.new(opts)
  end

end
