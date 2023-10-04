# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ghostest/version"

Gem::Specification.new do |spec|
  spec.name = "ghostest"
  spec.version = Ghostest::VERSION
  spec.authors = ["ryooo"]
  spec.email = ["ryooo.321@gmail.com"]

  spec.summary = "summary"
  spec.description = "description"
  spec.homepage = "https://github.com/ryooo"
  spec.required_ruby_version = ">= 3.2.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ryooo"
  spec.metadata["changelog_uri"] = "https://github.com/ryooo"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ config/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = ['ghostest']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.56"
  spec.add_dependency 'ruby-openai', '~> 5.1.0'
  spec.add_dependency 'html2markdown', '~> 0.0.3'
  spec.add_dependency 'addressable', '~> 2.8'
  spec.add_dependency 'baran', '~> 0.1.8'
  spec.add_dependency 'tiktoken_ruby', '~> 0.0.5'
  spec.add_dependency 'google-apis-customsearch_v1', '~> 0.15.0'
  spec.add_dependency 'colorize', '~> 1.1.0'
  spec.add_dependency 'i18n', '~> 1.14.1'
  spec.add_dependency 'indifference', '~> 0.0.1'

end
