# frozen_string_literal: true

module Ghostest
  class Manager
    include AttrReader
    attr_reader :config

    def initialize(config)
      @config = config
      @should_work_paths = []
      @test_condition = Ghostest::TestCondition.new(@config.language_klass)
    end

    # skip test for this method
    def start_work!
      logger = Ghostest::Logger.instance

      loop do
        wait_for_update(@config.watch_files)
        next if @should_work_paths.empty?

        @should_work_paths.each do |source_path, test_path|
          agents = @config.agents.map do |name, agent_config|
            agent_config.role_klass.new(name, @config, logger)
          end

          assignee = agents.first
          switch_assignee_function = Llm::Functions::SwitchAssignee.new(assignee, agents)
          i = 0
          while i < 10
            i += 1
            assignee.work(source_path:, test_path:, switch_assignee_function:)
            break if assignee.respond_to?('lgtm?') && assignee.lgtm?
            assignee = switch_assignee_function.assignee
          end
          if assignee.respond_to?('lgtm?') && assignee.lgtm?
            @test_condition.save_as_updated!(source_path)
          else
            raise Ghostest::Error, "Workers couldn't finish the work. "
          end
        end
      end
    end

    # skip test for this method
    def wait_for_update(watch_files)
      loop do
        sleep(3)
        should_work_paths = []
        watch_files.each do |watch_file|
          file_paths = Dir.glob(watch_file)

          file_paths.each do |source_path|
            if @test_condition.should_update_test?(source_path)
              test_path = @config.language_klass.convert_source_path_to_test_path(source_path)
              if File.exist?(test_path)
                should_work_paths << [source_path, test_path]
              else
                should_work_paths << [source_path, nil]
              end
            end
          end
        end

        unless should_work_paths.empty?
          @should_work_paths = should_work_paths
          break
        end
      end
    end
  end
end
