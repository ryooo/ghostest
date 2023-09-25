# frozen_string_literal: true

module Ghostest
  class Logger < ::Logger
    include Singleton
    def verbose
      @verbose ||= false
    end

    def verbose=(value)
      @verbose = value
    end

    def initialize
      super($stdout)

      self.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end

      self.level = Logger::INFO
    end

    def verbose_info(msg)
      info(msg) if verbose
    end

    def debug=(value)
      self.level = value ? Logger::DEBUG : Logger::INFO
    end
  end
end
