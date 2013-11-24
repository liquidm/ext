# encoding: utf-8

require 'digest'

class HashHelper
  def self.numeric_hash(val)
    # Use a the first 15 bytes of a MD5 bytes - small enough to be represented as Fixnum => no garbage collection
    Digest::MD5.hexdigest(val.to_s)[0..14].to_i(16)
  end
end
