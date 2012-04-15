require 'yaml'

class Section < Hash
  class << self
    def from_hash(hsh)
      new.tap do |result|
        hsh.each do |key, value|
          value = if value.is_a?(Hash)
                    from_hash(value)
                  elsif value.is_a?(Array)
                    value.map do |item|
                      from_hash(item)
                    end
                  else
                    value
                  end

          result[key.to_sym] = value
        end
      end
    end
  end

  def deep_merge(other_hash)
    self.merge(other_hash) do |key, oldval, newval|
      oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
      newval = newval.to_hash if newval.respond_to?(:to_hash)
      oldval.is_a?(Hash) && newval.is_a?(Hash) ? oldval.deep_merge(newval) : newval
    end
  end

  def deep_merge!(other_hash)
    replace(deep_merge(other_hash))
  end

  def method_missing(name, *args)
    if name.to_s[-1] == ?=
      self[name.to_s[0..-2].to_sym] = args.first
    else
      value = self[name]
      self[name] = value.call if value.is_a?(Proc)
      self[name]
    end
  end
end

class Configuration < Section
  def initialize(mode = :development)
    @mode = mode
    yield self if block_given?
  end

  def mixin(value)
    unless value.is_a?(Hash)
      value = Section.from_hash(YAML.load(File.read(file)))
    end

    if value.has_key?(:default)
      self.deep_merge!(value[:default])
    end

    if value.has_key?(:generic)
      self.deep_merge!(value[:generic])
    end

    if value.has_key?(@mode)
      self.deep_merge!(value[@mode])
    else
      self.deep_merge!(value)
    end
  end

  def load_mixins(path, mixins_to_use)
    mixins_to_use.map do |mixin_name|
      File.join(path, "#{mixin_name}.yml")
    end.each do |mixin_file|
      mixin(mixin_file)
    end
  end
end
