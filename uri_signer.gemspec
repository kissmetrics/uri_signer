# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uri_signer/version'

Gem::Specification.new do |spec|
  spec.name          = "uri_signer"
  spec.version       = UriSigner::VERSION
  spec.authors       = ["Nate Klaiber"]
  spec.email         = ["nklaiber@kissmetrics.com"]
  spec.description   = %q{ Handle the generation of a URI signature for API }
  spec.summary       = %q{ Given a client secret, we can digitally sign the URL and make requests to the API. }
  spec.homepage      = "https://github.com/kissmetrics/uri_signer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'addressable', '~> 2.2'
  spec.add_dependency 'ruby-hmac', '~> 0.4'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
end
