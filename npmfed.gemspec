# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'npmfed/version'

Gem::Specification.new do |spec|
  spec.name          = "npmfed"
  spec.version       = Npmfed::VERSION
  spec.license       = "GPL-2.0"
  spec.authors       = ["Tomas Hrcka"]
  spec.email         = ["thrcka@redhat.com"]

  spec.summary       = %q{Tool for checking and generating rpm packages from npm modules}
  spec.description   = %q{Tool for checking and generating rpm packages from npm modules based on npm2rpm by https://github.com/kkaempf}
  spec.homepage      = "https://github.com/humaton/npmfed"

  

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables << 'npmfed'
  spec.require_paths = ["lib"]

  spec.add_dependency "json", "~> 1.8"
  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "colorize", "~> 0.7"


  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.4"
end
