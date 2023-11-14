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
unless defined?(HashWithIndifferentAccess)
  require 'indifference'
end
require 'erb'
require 'bundler'

require "ghostest/attr_reader"
require "ghostest/config/agent"
require "ghostest/config"
require "ghostest/config_error"
require "ghostest/error"
require "ghostest/languages/ruby"
require "ghostest/logger"
require "ghostest/manager"
require "ghostest/test_condition"
require "ghostest/version"
require "ghostest"
require "google_custom_search"
require "i18n_translator"
require "initializers/i18n"

require "llm/message_container"
require "llm/agents/base"
require "llm/agents/reviewer"
require "llm/agents/test_designer"
require "llm/agents/test_programmer"
require "llm/clients/base"
require "llm/clients/azure_open_ai"
require "llm/clients/open_ai"
require "llm/functions/base"
require "llm/functions/add_to_memory"
require "llm/functions/exec_rspec_test"
require "llm/functions/fix_one_rspec_test"
require "llm/functions/get_files_list"
require "llm/functions/get_gem_files_list"
require "llm/functions/make_new_file"
require "llm/functions/overwrite_file"
require "llm/functions/read_file"
require "llm/functions/record_lgtm"
require "llm/functions/report_bug"
require "llm/functions/switch_assignee"

module Ghostest
end
