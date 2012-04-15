##
# Various Hash extensions.
#
class Hash

  # Recursively merge +other_hash+ into +self+ and return the new hash.
  def deep_merge(other_hash)
    self.merge(other_hash) do |key, oldval, newval|
      oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
      newval = newval.to_hash if newval.respond_to?(:to_hash)
      oldval.is_a?(Hash) && newval.is_a?(Hash) ? oldval.deep_merge(newval) : newval
    end
  end

  # Recursively merge and replace +other_hash+ into +self.
  def deep_merge!(other_hash)
    replace(deep_merge(other_hash))
  end

end
