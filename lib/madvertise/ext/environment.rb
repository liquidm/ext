class Environment
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def mode
    ENV[@key] || 'development'
  end

  def to_sym
    mode.to_sym
  end

  def prod?
    to_sym == :production
  end

  def dev?
    to_sym == :development
  end

  def test?
    to_sym == :test
  end

  def set(value)
    ENV[@key] = value.to_s
  end
end

Env = Environment.new
