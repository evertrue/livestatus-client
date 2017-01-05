# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'livestatus-client/version'

Gem::Specification.new do |spec|
  spec.name          = "livestatus-client"
  spec.version       = LivestatusClient::VERSION
  spec.authors       = ["Eric Herot"]
  spec.email         = ["eric.github@herot.com"]

  spec.summary       = 'This is a very "lightweight" command line client ' \
    '(written in Ruby) for the MK Livestatus Nagios module.'
  spec.homepage      = "https://github.com/evertrue/livestatus-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'trollop'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
