##
# A simple convenience class to support multiple environments in which a
# program can run (e.g. development, production, etc).
#
class Environment
  attr_accessor :key

  # Create a new Environment instance with the corresponding +key+ in the +ENV+
  # hash.
  #
  # @param [String] key  The key in +ENV+ to contain the current program
  #                      environment.
  #
  def initialize(key=nil)
    @key = key
  end

  # Retreive the current environment mode.
  #
  # @return [String]  The current environment mode.
  def mode
    ENV[@key] || 'development'
  end

  # Retrieve the current environment mode and convert it to a symbol.
  #
  # @return [Symbol]  The current environment mode.
  def to_sym
    mode.to_sym
  end

  # Return true if the current environment is +production+.
  def prod?
    to_sym == :production
  end

  # Return true if the current environment is +development+.
  def dev?
    to_sym == :development
  end

  # Return true if the current environment is +test+.
  def test?
    to_sym == :test
  end

  # Set the environment mode.
  #
  # @param [String]  The new environment mode.
  def set(value)
    ENV[@key] = value.to_s
  end
end

# Global instance of {Environment}.
Env = Environment.new
