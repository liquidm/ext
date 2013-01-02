# encoding: utf-8

require 'madvertise/ext/logging'
require 'servolux'
require 'servolux/cli'

module Servolux
  def self.init_config(cli_class)
    config = cli_class.parse_options

    # CLI.parse_options may have changed $0
    # so we reload the logger for good measure
    $log = init_logger
    $log.level = config[:debug] ? :debug : :info

    return config
  end

  def self.wrap(server_class)
    config = self.init_config(Servolux::CLI)
    server_class.new(config).run
  rescue => e
    $log.exception(e)
    raise e
  end

  def self.wrap_daemon(server_class)
    config = self.init_config(Servolux::DaemonCLI)

    server = server_class.new(config[:name], config.merge({
      interval: 1,
      logger: $log,
      pid_file: config[:pidfile]
    }))

    if config[:daemonize] or config[:kill]
      daemon = Servolux::Daemon.new(:server => server)

      if config[:kill]
        daemon.shutdown
      else
        daemon.startup
      end
    else
      server.startup
    end
  rescue => e
    $log.exception(e)
    raise e
  end
end
