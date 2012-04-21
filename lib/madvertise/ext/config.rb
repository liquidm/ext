require 'yaml'
require 'madvertise/ext/hash'

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

    # Create a new section from the given hash-like object.
    #
    # @param [Hash] hsh  The hash to convert into a section.
    # @return [Section]  The new {Section} object.
    def from_hash(hsh)
      result = new.tap do |result|
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
          from_hash(item)
        end
      else
        value
      end
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
    unless value.is_a?(Hash)
      value = Section.from_hash(YAML.load(File.read(value)))
    end

    self.deep_merge!(value[:default]) if value.has_key?(:default)
    self.deep_merge!(value[:generic]) if value.has_key?(:generic)

    if value.has_key?(@mode)
      self.deep_merge!(value[@mode])
    else
      self.deep_merge!(value)
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
      value = NilSection.new if value.nil?
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
  def initialize(mode = :development)
    @mode = mode
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

  ##
  # The {Helpers} module can be included in all classes that wish to load
  # configuration file(s). In order to load custom configuration files the
  # including class needs to set the +@config_file+ instance variable.
  #
  module Helpers

    # Load the configuration. The default configuration is located at
    # +lib/ganymed/config.yml+ inside the Ganymed source tree.
    #
    # @return [Configuration]  The configuration object. See madvertise-ext gem
    #                          for details.
    def config
      @config ||= Configuration.new(Env.mode) do |config|
        config.mixin(@default_config_file) if @default_config_file
        config.mixin(@config_file) if @config_file
      end
    end
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
