# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aurum/version'

Gem::Specification.new do |spec|
  spec.name          = "aurum"
  spec.version       = Aurum::VERSION
  spec.authors       = ["Anthony Eufemio"]
  spec.email         = ["ace@dgx.io"]

  spec.summary       = %q{Pre-processor tools for the Solidity contract programming language}
  spec.description   = %q{Enables easier development workflow for Solidity contracts.}
  spec.homepage      = "https://github.com/digixglobal"
  spec.license       = "BSD-2"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exec"
  spec.executables   = spec.files.grep(%r{^exec/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "awesome_print", "~> 1.6"
  spec.add_dependency "activesupport", "~> 4.2"
  spec.add_dependency "pry", "~> 0.10"
  spec.add_dependency "colorize", "~> 0.7"
end
