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

  # load bundled jars
  Dir[File.join(File.dirname(__FILE__), '*.jar')].each do |f|
    require f
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
require 'liquid/metrics'
require 'liquid/server'
require 'liquid/timing'
require 'liquid/tracker'
require 'liquid/transaction_id'
require 'liquid/zmq'

# configuration callbacks
require 'liquid/logger'
reload_logger = ->(conf) do
  $log ||= Liquid::Logger.new("root")
  $log.reload!
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

require 'liquid/configuration'
$conf = Liquid::Configuration.new

$conf.mixin({
  generic: {
    log: {
      caller: false,
      level: :info,
      format: "%d{ISO8601} %-5p #{File.basename($0)}(#{Process.pid})[%t]: %m%n",
    },
    tracker: {
      dimensions: {},
      kafka: {
        enabled: false,
        brokers: [
          '0.0.0.0:9092'
        ]
      },
    },
    zmachine: {
      debug: false,
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

$conf.callback(&reload_mixins)
$conf.callback(&reload_logger)
$conf.reload!

if $conf.code_reloader
  require 'liquid/code_reloader'
  $:.each do |path|
    next unless File.directory?(path)
    CodeReloader.new(path)
  end
end
