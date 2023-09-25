module Llm
  module Agents
    class TestProgrammer < Base

      # skip test for this method
      def work(
        source_path: raise("source_path is required"),
        test_path: nil,
        switch_assignee_function: raise("switch_assignee_function is required"))

        say("start to work for #{source_path}")

        message_container = Llm::MessageContainer.new
        test_path ||= self.config.language_klass.convert_source_path_to_test_path(source_path)
        message_container.add_system_message(self.agent_config.system_prompt.gsub("%{source_path}", source_path).gsub("%{test_path}", test_path))

        if switch_assignee_function.messages.size > 0
          message_container.add_system_message(I18n.t('agents.test_programmer.last_assignee_comment',
                                                      last_assignee: switch_assignee_function.last_assignee,
                                                      comment: switch_assignee_function.last_message))
        end

        azure_open_ai = Llm::Clients::AzureOpenAi.new
        io = azure_open_ai.chat_with_function_calling_loop(
          messages: message_container,
          functions: [
            Llm::Functions::GetFilesList.new,
            Llm::Functions::ReadFile.new,
            Llm::Functions::OverwriteFile.new,
            Llm::Functions::MakeNewFile.new,
            Llm::Functions::AddToMemory.new(message_container),
            Llm::Functions::ReportBug.new,
            switch_assignee_function,

          ] + self.config.language_klass.create_functions,
          agent: self,
        )

        comment = io.rewind && io.read
        say(comment)
        comment
      end
    end
  end
end
