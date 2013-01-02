require 'yaml'
require 'set'

require 'madvertise/ext/hash'
require 'madvertise/ext/environment'

##
# A {Configuration} consists of one or more Sections. A section is a hash-like
# object that responds to all keys in the hash as if they were methods:
#
#   > s = Section.from_hash({:v1 => 2, :nested => {:v2 => 1}})
#   > s.v1
#   => 2
#   > s.nested.v2
#   => 1
#
class Section < Hash

  class << self

    # How to handle nil values in the configuration?
    #
    # Possible values are:
    #  - :nil, nil  (return nil)
    #  - :raise  (raise an exception)
    #  - :section  (return a NilSection which can be chained)
    #
    attr_accessor :nil_action

    # Create a new section from the given hash-like object.
    #
    # @param [Hash] hsh  The hash to convert into a section.
    # @return [Section]  The new {Section} object.
    def from_hash(hsh)
      new.tap do |result|
        hsh.each do |key, value|
          result[key.to_sym] = from_value(value)
        end
      end
    end

    # Convert the given value into a Section, list of Sections or the pure
    # value. Used to recursively build the Section hash.
    #
    # @private
    def from_value(value)
      case value
      when Hash
        from_hash(value)
      when Array
        value.map do |item|
          from_value(item)
        end
      else
        value
      end
    end

  end

  # Build the call chain including NilSections.
  #
  # @private
  def method_missing(name, *args)
    if name.to_s =~ /(.*)=$/
      self[$1.to_sym] = Section.from_value(args.first)
    else
      value = self[name]
      value = value.call if value.is_a?(Proc)

      if value.nil?
        case self.class.nil_action
        when :nil, nil
          # do nothing
        when :raise
          raise "value is nil for key #{name}"
        when :section
          value = NilSection.new if value.nil?
        else
          raise "unknown nil handling: #{self.class.nil_action}"
        end
      end

      self[name] = value
    end
  end
end

##
# The Configuration class provides a simple interface to configuration stored
# inside of YAML files.
#
class Configuration < Section

  # Create a new {Configuration} object.
  #
  # @param [Symbol] mode  The mode to load from the configurtion file
  #                       (production, development, etc)
  # @yield [config]  The new configuration object.
  def initialize
    @mixins = Set.new
    @callbacks = []
    yield self if block_given?
  end

  # Load given mixins from +path+.
  #
  # @param [String] path  The path to mixin files.
  # @param [Array] mixins_to_use  A list of mixins to load from +path+.
  # @return [void]
  def load_mixins(path, mixins_to_use)
    mixins_to_use.map do |mixin_name|
      File.join(path, "#{mixin_name}.yml")
    end.each do |mixin_file|
      mixin(mixin_file)
    end
  end

  # Mixin a configuration snippet into the current section.
  #
  # @param [Hash, String] value  A hash to merge into the current
  #                              configuration. If a string is given a filename
  #                              is assumed and the given file is expected to
  #                              contain a YAML hash.
  # @return [void]
  def mixin(value)
    if value.is_a?(String)
      @mixins << value
      value = YAML.load(File.read(value))
    end

    value = Section.from_hash(value)

    self.deep_merge!(value[:default]) if value.has_key?(:default)
    self.deep_merge!(value[:generic]) if value.has_key?(:generic)

    if value.has_key?(Env.to_sym)
      self.deep_merge!(value[Env.to_sym])
    else
      self.deep_merge!(value)
    end

    @callbacks.each do |callback|
      callback.call
    end
  end

  # Reload all mixins.
  #
  # @return [void]
  def reload!
    self.clear
    @mixins.each do |file|
      self.mixin(file)
    end
  end

  # Register a callback for config mixins.
  #
  # @return [void]
  def callback(&block)
    @callbacks << block
  end

end

##
# A NilSection is returned for all missing/empty values in the config file. This
# allows for terse code when accessing values that have not been configured by
# the user.
#
# Consider code like this:
#
#   config.server.listen.tap do |listen|
#     open_socket(listen.host, listen.port)
#   end
#
# Given that your server component is optional and does not appear in the
# configuration file at all, +config.server.listen+ will return a NilSection
# that does not call the block given to tap _at all_.
#
class NilSection
  # @return true
  def nil?
    true
  end

  # @return true
  def empty?
    true
  end

  # @return false
  def present?
    false
  end

  # @return nil
  def tap
    nil
  end

  # @private
  def method_missing(*args, &block)
    self
  end
end
