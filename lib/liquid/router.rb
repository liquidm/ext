# encoding: utf-8

require 'liquid/from_file'

class Router
  include FromFile

  attr_accessor :routes

  def initialize(request_handler)
    @request_handler = request_handler
    @routes = []

    @cache = Hash.new do |hash, path|
      hash[path] = nil
      @routes.each do |regex, block, args|
        match = path.match(regex)
        hash[path] = block.curry[match] if match
      end
      hash[path]
    end
  end

  def add(regexp, args, &block)
    @routes << [regexp, block, args]
  end

  # route %r(/foo/(.+)/(\w+)/(\d+)), AnyParser, :matches, :in, :order
  def route(regexp, parser, *args, &block)
    block = lambda do |match, env|
      params = args.each_with_index.inject({}) do |hash, (name, index)|
        hash[name] = match[index+1]
        hash
      end

      return @request_handler.handle(parser, env, params)
    end

    add(regexp, args, &block)
  end

  def handle(path, request)
    @cache[path].call(request) if @cache[path]
  end
end
