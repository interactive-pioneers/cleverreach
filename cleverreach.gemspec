
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cleverreach/version'

Gem::Specification.new do |spec|
  spec.name          = 'cleverreach'
  spec.version       = Cleverreach::VERSION
  spec.authors       = ['Meinhard Gredig', 'Georg Meyer']
  spec.email         = ['mgd@interactive-pioneers.de', 'gm@interactive-pioneers.de']
  spec.summary       = 'Ruby wrapper for Cleverreach REST-API.'
  spec.description   = 'Ruby wrapper for Cleverreach email marketing software REST-API.'
  spec.homepage      = 'https://github.com/interactive-pioneers/cleverreach'
  spec.license       = 'GPL-3.0'
  spec.required_ruby_version = '>= 2.2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-nc', '~> 0.3'
  spec.add_development_dependency 'rubocop', '~> 0.50'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.18'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
