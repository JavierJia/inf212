# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frequencies_2/version'

Gem::Specification.new do |spec|
  spec.name          = "frequencies_2"
  spec.version       = Frequencies2::VERSION
  spec.authors       = ["JavierJia"]
  spec.email         = ["jianfeng.jia@gmail.com"]
  spec.summary       = 'Inf 212 Frequencies2'
  spec.description   = 'Inf 212 Frequencies2'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
