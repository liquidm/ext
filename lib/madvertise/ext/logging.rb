# encoding: utf-8

require 'madvertise/ext/environment'
require 'madvertise-logging'

def init_logger(progname=$0, filename=nil)
  progname = File.basename(progname)
  filename ||= "#{Env.mode}.log"

  MultiLogger.new.tap do |logger|
    init_multi_logger(logger, progname, filename)
  end
end

def init_multi_logger(logger, progname=$0, filename=nil)
  if Env.dev? or Env.test?
    logger.attach(ImprovedLogger.new(STDERR, progname))
  else
    logger.attach(ImprovedLogger.new(:syslog, progname))
  end

  # default log level
  logger.level = Logger::INFO
end

$log = init_logger
