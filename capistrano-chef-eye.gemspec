# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/chef_eye/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-chef-eye'
  spec.version       = Capistrano::ChefEye::VERSION
  spec.authors       = ['Nikolay Murga']
  spec.email         = ['nikolay.m@murga.kiev.ua']
  spec.summary       = %q{Chef Eye plugin companion for Capistrano.}
  spec.description   = %q{Chef Eye plugin companion for Capistrano.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
