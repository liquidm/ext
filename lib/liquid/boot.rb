# encoding: utf-8

if defined?(ROOT)
  $:.unshift(File.join(ROOT, 'lib'))
  $:.unshift(ROOT)
end

# load java dependencies
if RUBY_PLATFORM == 'java'
  begin
    require 'jbundler'
  rescue LoadError
    # do nothing
  end

  begin
    require 'lock_jar'
    LockJar.load
  rescue LoadError
    # do nothing
  end

  # some java libraries cannot be found on maven central, so we load all bundled
  # jar files here for convenience
  if defined?(ROOT)
    Dir[File.join(ROOT, 'jars', '*.jar')].each do |f|
      require f
    end
  end
end

# load a bunch of common classes here, so we don't have to track and repeat it
# everywhere
require 'active_support/all'
require 'cgi'
require 'date'
require 'json'
require 'socket'
require 'time'

# load all extensions
Dir[File.join(File.dirname(__FILE__), 'ext', '*.rb')].each do |f|
  require f
end

require 'liquid/benchmark'
require 'liquid/cli'
require 'liquid/environment'
require 'liquid/from_file'
require 'liquid/hash_helper'
require 'liquid/timing'
require 'liquid/transaction_id'

# configuration callbacks
require 'liquid/metrics'
start_metrics = ->(conf) do
  Metrics.start
  Signal.register_shutdown_handler { Metrics.stop }
end

require 'liquid/logger'
reload_logger = ->(conf) do
  $log = Liquid::Logger.new("root")
end

load_defaults = ->(conf) do
  conf.mixin({
    generic: {
      log: {
        caller: false,
        level: :info,
        format: "%d{ISO8601} %-5p #{File.basename($0)}(#{Process.pid})[%t]: %m%n",
      },
    },
    production: {
      log: {
        format: "[%t]: %m%n",
      },
    },
    staging: {
      log: {
        format: "[%t]: %m%n",
      },
    },
  })
end

reload_mixins = ->(conf) do
  if defined?(ROOT)
    config_yml = File.join(ROOT, 'config.yml')
    conf.mixin(config_yml) if File.exist?(config_yml)
    dot_user = File.join(ROOT, '.user')
    if File.exists?(dot_user)
      File.readlines(dot_user).each do |line|
        user_yml = File.join(ROOT, 'config', 'mixins', "#{line.chomp}.yml")
        conf.mixin(user_yml)
      end
    end
  end
end

# reload configuration, trigger callbacks
require 'liquid/configuration'
$conf = Liquid::Configuration.new
$conf.callback(&load_defaults)
$conf.callback(&reload_mixins)
$conf.callback(&reload_logger)
$conf.callback(&start_metrics)
$conf.reload!
