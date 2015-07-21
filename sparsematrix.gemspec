# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sparsematrix/version'

Gem::Specification.new do |spec|
  spec.name          = 'sparsematrix'
  spec.version       = SparseMatrix::VERSION
  spec.authors       = ['Reed Kraft-Murphy']
  spec.email         = ['reed@reedmurphy.net']

  spec.summary       = 'Sparse matrix implementations (just Yale currently) in pure Ruby.'
  spec.description   = 'Sparse matrix implementations (just Yale currently) in pure Ruby.'
  spec.homepage      = 'https://github.com/RWJMurphy/ruby-sparsematrix'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'stackprof'
  spec.add_development_dependency 'yard'
end
