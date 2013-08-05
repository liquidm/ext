require 'singleton'
require 'metriks'
require 'metriks/reporter/logger'

class Statistics
  include Singleton

  def initialize
    Metriks::Reporter::Logger.new(:logger => $log, :interval => 300).start
  end
end
