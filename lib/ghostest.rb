require_relative "ghostest/version"

require 'openai'
require 'html2markdown'
require 'addressable'
require 'baran'
require 'tiktoken_ruby'
require 'google-apis-customsearch_v1'
require 'colorize'
require 'pry'
require 'i18n'

Dir[File.expand_path("lib/**/*.rb")].each do |file|
  require file
end

module Ghostest
  def self.wakeup!
    puts "Ghostest.wakeup!"
  end
  class Error < StandardError; end
end
