class FooHandler; end

route %r(/bidrequest/(\w+)), FooHandler, :site_token
route %r(/bid/(\w+)), FooHandler, :token
