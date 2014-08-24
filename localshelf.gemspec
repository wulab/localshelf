# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localshelf/version'

Gem::Specification.new do |spec|
  spec.name          = "localshelf"
  spec.version       = Localshelf::VERSION
  spec.authors       = ["Weera Wu"]
  spec.email         = ["weera@oozou.com"]
  spec.summary       = %q{Ebook shelf for a group}
  spec.description   = %q{Localshelf allows users to manage and share their ebooks within a local network through its web interface.}
  spec.homepage      = "https://github.com/wulab/localshelf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "sqlite3"
  spec.add_runtime_dependency "epubinfo"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
