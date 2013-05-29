# encoding: utf-8

begin
  require 'jbundler'
rescue LoadError
  # do nothing
end

# load a bunch of common classes here, so we don't have to track and repeat it
# everywhere
require 'active_support/all'
require 'cgi'
require 'date'
require 'json'
require 'servolux'
require 'socket'

# load all madvertise extensions
Dir[File.join(File.dirname(__FILE__), 'ext', '*.rb')].each do |f|
  require f
end

Dir[File.join(File.dirname(__FILE__), '*.rb')].each do |f|
  require f unless f == 'tasks.rb' # skip special rake tasks
end

require 'madvertise/logging' # dedicated gem

# initialize configuration and logger with hardcoded defaults
$conf = Conf = Configuration.new
$conf.callback do
  ImprovedLogger::Formatter.format = $conf.log_format
  $log = MultiLogger.new
  $log.attach(ImprovedLogger.new($conf.log_backend.to_sym, File.basename($0)))
  $log.level = $conf.log_level.downcase.to_sym
  $log.log_caller = $conf.log_caller
end

# trigger log callback with defaults
$conf.reload!
