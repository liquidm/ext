require 'ffi'
require 'ffi/tools/const_generator'

module Sysconf
  extend FFI::Library
  ffi_lib ["c"]

  fcg = FFI::ConstGenerator.new do |gen|
    gen.include 'unistd.h'

    %w[
    _SC_PAGE_SIZE
    _SC_VERSION
    ].each do |const|
      ruby_name = const.sub(/^_SC_/, '').downcase.to_sym
      gen.const(const, "%d", nil, ruby_name, &:to_i)
    end
  end

  CONF = enum(*fcg.constants.map{|_, const|
    [const.ruby_name, const.converted_value]
  }.flatten)

  attach_function :sysconf, [CONF], :long
end
