# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'testing_your_legacy/version'

Gem::Specification.new do |spec|
  spec.name          = "testing_your_legacy"
  spec.version       = YourLegacyTests::VERSION
  spec.authors       = ["Timothy Nordloh"]
  spec.email         = ["tnordloh@gmail.com"]

  spec.summary       = %q{Use Sumo Logic to generate tests for a Rails application, based on most frequently visited urls }
  spec.homepage      = "https://github.com/tnordloh/testing_your_legacy"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "sumo-search", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
