# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ghostest/version"

Gem::Specification.new do |spec|
  spec.name = "ghostest"
  spec.version = Ghostest::VERSION
  spec.authors = ["ryooo"]
  spec.email = ["ryooo.321@gmail.com"]

  spec.summary = "Test code generator by llm"
  spec.description = "Output test code using LLM agents."
  spec.homepage = "https://github.com/ryooo/ghostest"
  # spec.required_ruby_version = ">= 3.2.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ryooo/ghostest"
  spec.metadata["changelog_uri"] = "https://github.com/ryooo/ghostest"

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

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_dependency 'ruby-openai'
  spec.add_dependency 'html2markdown'
  spec.add_dependency 'addressable'
  spec.add_dependency 'baran'
  spec.add_dependency 'tiktoken_ruby'
  spec.add_dependency 'google-apis-customsearch_v1'
  spec.add_dependency 'colorize'
  spec.add_dependency 'i18n'
  spec.add_dependency 'indifference'

end
