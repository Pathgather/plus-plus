# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plus_plus/version'

Gem::Specification.new do |spec|
  spec.name          = "plus_plus"
  spec.version       = PlusPlus::VERSION
  spec.authors       = ["Pathgather"]
  spec.email         = ["tech@pathgather.com"]
  spec.description   = spec.summary = %q{counter_cache, but much more powerful}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec-rails", "~> 2.14"
  spec.add_development_dependency "factory_girl", "~> 4.4.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activerecord", "~> 4.1.4"
  spec.add_development_dependency "sqlite3"
end