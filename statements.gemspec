# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'statements/version'

Gem::Specification.new do |spec|
  spec.name          = 'statements'
  spec.version       = Statements::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil@helium.net.au']
  spec.summary       = 'Turn PDF bank statements into a useful database'
  spec.description   = ''
  spec.homepage      = 'https://github.com/hx/statements'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.2'
  spec.add_dependency 'sqlite3', '~> 1.3'
  spec.add_dependency 'thin', '~> 1.6'
  spec.add_dependency 'sinatra', '~> 1.4'

  spec.add_development_dependency 'rspec', '~> 3.1'
end
