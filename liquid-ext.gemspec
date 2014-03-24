# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "liquid-ext"
  spec.version       = "3.3.0"
  spec.authors       = ["LiquidM, Inc."]
  spec.email         = ["opensource@liquidm.com"]
  spec.description   = %q{Ruby core extensions and helper libraries}
  spec.summary       = %q{Ruby core extensions and helper libraries}
  spec.homepage      = "https://github.com/liquidm/ext"
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "erubis"
  spec.add_dependency "jmx4r"
  spec.add_dependency "mixlib-cli"
  spec.add_dependency "terminal-table"
end
