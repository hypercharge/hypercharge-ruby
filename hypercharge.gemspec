# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hypercharge/version'

Gem::Specification.new do |spec|
  spec.name          = "hypercharge"
  spec.version       = Hypercharge::VERSION
  spec.authors       = ["Luzifer Altenberg"]
  spec.email         = ["luzifer@atomgas.de"]
  # spec.description   = %q{Ruby SDK Write a gem description}
  spec.summary       = %q{Ruby SDK for the hypercharge payment gateway}
  spec.homepage      = "https://secure.sankyu.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'hypercharge-schema', '~>1.24.5'
  spec.add_runtime_dependency 'builder',            '>=2.1.2'
  spec.add_runtime_dependency 'renum',              '~>1.4.0'
  spec.add_runtime_dependency 'addressable',        '~>2.3.3'
  spec.add_runtime_dependency 'faraday',            '~>0.8.7'
  spec.add_runtime_dependency 'faraday_middleware', '~>0.9.0'
  spec.add_runtime_dependency 'multi_xml',          '~>0.5.3'


  spec.add_development_dependency 'webmock',  '~>1.11.0'
  spec.add_development_dependency 'bundler',  '~>1.3.5'
  spec.add_development_dependency 'minitest', '~>5.0.4'
  spec.add_development_dependency 'mechanize','~>2.7.1'
  spec.add_development_dependency 'mocha',    '~>0.14.0'

end
