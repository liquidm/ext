require 'active_support/core_ext/module/attribute_accessors'
require 'madvertise/ext/environment'
require 'madvertise-logging'

include Madvertise::Logging

##
# The {Logging} module provides a global container for the logger object.
#
module Logging
  mattr_accessor :logger
  self.logger = nil

  # @private
  def self.create_logger
    if Env.prod?
      ImprovedLogger.new(:syslog, $0)
    else
      ImprovedLogger.new(STDERR, $0)
    end.tap do |logger|
      logger.level = :info
    end
  end

  ##
  # The {Logging::Helpers} module can be included in classes that wish to use
  # the global logger.
  #
  module Helpers

    # Retreive and possibly create the global logger object.
    #
    # @return [Logger]  The logger object.
    def log
      Logging.logger ||= Logging.create_logger
    end
  end
end
