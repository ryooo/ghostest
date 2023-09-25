# don't need to test this file
require_relative "ghostest/version"

require 'digest'

require 'openai'
require 'html2markdown'
require 'addressable'
require 'baran'
require 'tiktoken_ruby'
require 'google-apis-customsearch_v1'
require 'colorize'
require 'pry'
require 'i18n'
require 'indifference'
require 'erb'
require 'bundler'

require 'llm/functions/base'
require "llm/clients/base"
Dir[File.expand_path("lib/**/*.rb")].each do |file|
  require file
end

module Ghostest
end
