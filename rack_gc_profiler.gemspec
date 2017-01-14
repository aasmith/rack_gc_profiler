# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack_gc_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "rack_gc_profiler"
  spec.version       = RackGcProfiler::VERSION
  spec.authors       = ["Andrew A Smith"]
  spec.email         = ["andy@tinnedfruit.org"]

  spec.summary       = %q{A rack middleware for measuring GC activity during a request.}
  spec.homepage      = "http://github.com/aasmith/rack_gc_profiler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
