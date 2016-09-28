# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpredict/version'

Gem::Specification.new do |spec|
  spec.name          = "rpredict"
  spec.version       = RPredict::VERSION
  spec.authors       = ["Luiz Gustavo Lourenço Moura"]
  spec.email         = ["lglmoura@gmail.com"]
  spec.summary       = %q{a real-time satellite tracking and orbit prediction application in Ruby.}
  spec.description   = %q{a real-time satellite tracking and orbit prediction application in Ruby.  inspiration PREDICT}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry-rails'
end
