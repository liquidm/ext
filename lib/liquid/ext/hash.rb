##
# Various Hash extensions.
#
class Hash

  # accumulate existing keys from +other_hash+ into +self+.
  def delta_merge!(other_hash)
    other_hash.each do |k,v|
      if self.has_key?(k)
        self[k] += v
      else
        self[k] = v
      end
    end
  end

end
