lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-tcp_mc"
  spec.version = "0.3.0"
  spec.authors = ["David Pippenger"]
  spec.email   = ["riven@particle-man.com"]

  spec.summary       = %q{Purpose built plugin for fluentd to send json over tcp.}
  spec.description   = %q{Purpose built plugin for fluentd to send json over tcp.}
  spec.homepage      = "https://github.com/particle-man/fluent-plugin-tcp_mc"
  spec.license       = "Apache-2.0"

  spec.required_ruby_version = ">= 2.4.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit", "~> 3.6"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "yajl-ruby", "~> 1.4"
end
