# encoding: utf-8

$:.unshift(ROOT) if defined?(ROOT)

# load default configuration
require 'madvertise-logging'
require 'madvertise/configuration'

$conf = Configuration.new

# configuration-reloading callbacks
reload_logger = ->(conf) do
  ImprovedLogger::Formatter.format = conf.log_format
  ImprovedLogger::Formatter.log4j_format = conf.log4j_format

  $log = MultiLogger.new
  $log.attach(ImprovedLogger.new(conf.log_backend.to_sym, File.basename($0)))
  $log.level = conf.log_level.downcase.to_sym
  $log.log_caller = conf.log_caller
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

# load java dependencies
if RUBY_PLATFORM == 'java'
  begin
    require 'jbundler'
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

# load all madvertise extensions
Dir[File.join(File.dirname(__FILE__), 'ext', '*.rb')].each do |f|
  require f
end

require 'madvertise/cli'
require 'madvertise/environment'
require 'madvertise/from_file'
require 'madvertise/hash_helper'
require 'madvertise/transaction_id'
