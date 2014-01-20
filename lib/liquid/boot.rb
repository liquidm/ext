# encoding: utf-8

$:.unshift(ROOT) if defined?(ROOT)

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

# load default configuration
require 'liquid-logging'
require 'liquid/configuration'

$conf = Configuration.new

# configuration-reloading callbacks
reload_logger = ->(conf) do
  ImprovedLogger::Formatter.format = conf.log_format
  ImprovedLogger::Formatter.log4j_format = conf.log4j_format

  $log = MultiLogger.new
  $log.attach(ImprovedLogger.new(conf.log_backend.to_sym, File.basename($0)))
  $log.level = conf.log_level.downcase.to_sym
  $log.log_caller = conf.log_caller

  # sneak this in automatically
  ZK.logger = $log if ::Module.const_defined?(:ZK)
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
$conf.callback(&reload_mixins)
$conf.callback(&reload_logger)

$conf.reload!

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
