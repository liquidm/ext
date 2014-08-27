# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'liquid-ext'
  spec.version       = '3.5.2'
  spec.authors       = ['LiquidM, Inc.']
  spec.email         = ['opensource@liquidm.com']
  spec.description   = %q{LiquidM ruby core extensions and helper libraries}
  spec.summary       = %q{A collection of common utilities used in various LiquidM projects}
  spec.homepage      = 'https://github.com/liquidm/ext'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 0'
  spec.add_dependency 'erubis', '~> 0'
  spec.add_dependency 'jmx4r', '~> 0'
  spec.add_dependency 'mixlib-cli', '~> 0'
  spec.add_dependency 'multi_json', '~> 0'
  spec.add_dependency 'terminal-table', '~> 0'
end
