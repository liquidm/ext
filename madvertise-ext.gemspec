# -*- encoding: utf-8 -*-
require File.expand_path('../lib/madvertise/ext/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "madvertise-ext"
  gem.version       = Madvertise::Ext::VERSION
  gem.authors       = ["Benedikt Böhm"]
  gem.email         = ["benedikt.boehm@madvertise.com"]
  gem.description   = %q{Ruby extensions}
  gem.summary       = %q{Ruby extensions}
  gem.homepage      = "https://github.com/madvertise/ext"

  gem.add_dependency "madvertise-logging"
  gem.add_dependency "mixlib-cli"
  gem.add_dependency "servolux"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
