# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "madvertise-ext"
  spec.version       = "0.9.3"
  spec.authors       = ["madvertise Mobile Advertising GmbH"]
  spec.email         = ["tech@madvertise.com"]
  spec.description   = %q{Ruby core extensions and helper libraries}
  spec.summary       = %q{Ruby core extensions and helper libraries}
  spec.homepage      = "https://github.com/madvertise/ext"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "ffi"
  spec.add_dependency "madvertise-logging", ">= 1.2.1"
  spec.add_dependency "metriks"
  spec.add_dependency "mixlib-cli"
end
