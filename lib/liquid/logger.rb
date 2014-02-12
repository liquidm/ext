require 'liquid/ext/string'

require_relative '../slf4j-api-1.7.6.jar'
require_relative '../slf4j-log4j12-1.7.6.jar'
require_relative '../log4j-1.2.17.jar'
java_import 'org.slf4j.LoggerFactory'

module Liquid
  class Logger

    attr_accessor :progname

    def initialize(name, progname = nil)
      @progname = progname || File.basename($0)
      @logger = LoggerFactory.getLogger(name)
      @exceptions = {}
      root = org.apache.log4j.Logger.getRootLogger
      appender = org.apache.log4j.ConsoleAppender.new
      appender.name = "console"
      appender.layout = org.apache.log4j.PatternLayout.new($conf.log_format)
      appender.threshold = org.apache.log4j.Level.toLevel($conf.log_level.to_s)
      appender.activateOptions
      root.removeAllAppenders
      root.addAppender(appender)
    end

    def trace?
      @logger.trace_enabled?
    end

    def trace(*args, &block)
      return unless trace?
      args = yield if block_given?
      @logger.trace(format(*args))
    end

    def debug?
      @logger.debug_enabled?
    end

    def debug(*args, &block)
      return unless debug?
      args = yield if block_given?
      @logger.debug(format(*args))
    end

    def info?
      @logger.info_enabled?
    end

    def info(*args, &block)
      return unless info?
      args = yield if block_given?
      @logger.info(format(*args))
    end

    def warn?
      @logger.warn_enabled?
    end

    def warn(*args, &block)
      return unless warn?
      args = yield if block_given?
      @logger.warn(format(*args))
    end

    def error?
      @logger.error_enabled?
    end

    def error(*args, &block)
      return unless error?
      args = yield if block_given?
      @logger.error(format(*args))
    end

    def exception(exc, message = nil, attribs = {})
      ::Metrics.meter("exception:#{exc.class}").mark
      @exceptions[exc.class] ||= {}
      @exceptions[exc.class][exc.backtrace.first] ||= [System.nano_time, 1, 1]
      five_minutes_ago = System.nano_time - 300_000_000_000
      last, count, backoff = *@exceptions[exc.class][exc.backtrace.first]
      count = backoff = 1 if last < five_minutes_ago
      backoff = count > backoff ? backoff * 2 : backoff
      if count % backoff == 0
        error("exception", {
          class: exc.class,
          count: count,
          reason: exc.message,
          message: message,
          backtrace: exc.backtrace
        }.merge(attribs).merge(called_from))
      end
      @exceptions[exc.class][exc.backtrace.first] = [
        System.nano_time,
        count + 1,
        backoff
      ]
    end

    private

    def format(message, attribs = {})
      attribs.merge!(called_from) if $conf.log_caller
      attribs = attribs.map do |k,v|
        "#{k}=#{v.to_s.clean_quote}"
      end.join(' ')
      message += " #{attribs}" if attribs.length > 0
      message
    end

    # Return the first callee outside the liquid-ext gem
    def called_from
      location = caller.detect('unknown:0') do |line|
        line.match(/\/liquid(-|\/)ext/).nil?
      end
      file, line, _ = location.split(':')
      { :file => file, :line => line }
    end

  end
end
