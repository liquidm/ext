require 'active_support/core_ext/module/attribute_accessors'
require 'madvertise/ext/environment'
require 'madvertise-logging'

##
# The {Logging} module provides a global container for the logger object.
#
module Logging
  mattr_accessor :logger
  self.logger = nil

  # @private
  def self.create_logger
    if Env.prod?
      Madvertise::Logging::ImprovedLogger.new(:syslog, $0)
    else
      Madvertise::Logging::ImprovedLogger.new(STDERR, $0)
    end.tap do |logger|
      logger.level = :info
    end
  end

  ##
  # The {Logging::Helpers} module is mixed into the Object class to make the
  # logger available to every object in the system.
  #
  module Helpers

    # Retreive and possibly create the global logger object.
    #
    # @return [Logger]  The logger object.
    def log
      ::Logging.logger ||= ::Logging.create_logger
    end
  end
end

class ::Object
  include ::Logging::Helpers
end
