# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'has_changelogs/version'

Gem::Specification.new do |spec|
  spec.name          = 'has_changelogs'
  spec.version       = HasChangelogs::VERSION
  spec.authors       = ['Elizabeth Brae', 'Christoph Beck']
  spec.email         = ["info@bitcrowd.net"]

  spec.summary       = %q{has_changelogs tracks changes on a model and it's associations for applications that need to have change history.}
  spec.description   = %q{has_changelogs tracks changes on a model and it's associations for applications that need to have change history. This is not about versioning your model, and the version is however, 0.1.0, so use at your own perril. The changelogs contain a JSON representation of the changes.}
  spec.homepage      = "https://github.com/bitcrowd/has_changelogs"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "activerecord"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

end
