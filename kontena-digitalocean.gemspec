# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kontena/digital_ocean'

Gem::Specification.new do |spec|
  spec.name          = "kontena-digitalocean"
  spec.version       = Kontena::DigitalOcean::VERSION
  spec.authors       = ["Jari Kolehmainen"]
  spec.email         = ["jari.kolehmainen@gmail.com"]
  spec.summary       = %q{Kontena DigitalOcean provisioner}
  spec.description   = %q{}
  spec.homepage      = "http://www.kontena.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "droplet_kit", "~> 1.2"
  spec.add_runtime_dependency "commander", "~> 4.3"
  spec.add_runtime_dependency "net-ssh", "~> 2.9"
  spec.add_runtime_dependency "net-scp", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
