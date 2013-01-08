# encoding: utf-8

require 'madvertise/ext/logging'
require 'servolux'
require 'servolux/cli'

module Servolux
  def self.parse_opts(cli_class)
    opts = cli_class.parse_options

    # CLI.parse_options may have changed $0
    # so we reload the logger for good measure
    $log = init_logger
    $log.level = opts[:debug] ? :debug : :info

    return opts
  end

  def self.wrap(server_class)
    opts = self.parse_opts(Servolux::CLI)
    server_class.new(opts).run
  rescue => e
    $log.exception(e)
    raise e
  end

  def self.wrap_daemon(server_class)
    opts = self.parse_opts(Servolux::DaemonCLI)

    server = server_class.new(opts[:name], opts.merge({
      interval: 1,
      logger: $log,
      pid_file: opts[:pidfile]
    }))

    if opts[:daemonize] or opts[:kill]
      daemon = Servolux::Daemon.new(:server => server)

      if opts[:kill]
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
