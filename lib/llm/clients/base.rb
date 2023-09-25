require "ghostest/attr_reader"
module Llm
  module Clients
    class Base
      include AttrReader
      attr_reader :client

      def chat(parameters: {})
        parameters = parameters.with_indifferent_access
        if parameters[:messages].nil? || parameters[:messages].empty?
          raise 'messages is required.'
        end
        parameters[:temperature] ||= 0.5
        parameters[:top_p] ||= 1
        parameters[:frequency_penalty] ||= 0
        parameters[:presence_penalty] ||= 0

        self.client.chat(parameters:)
      end

      def chat_with_function_calling_loop(**args)
        agent = args.delete(:agent) || (raise 'agent is required.')
        chat_message_io = StringIO.new

        if args[:messages].is_a?(Llm::MessageContainer)
          message_container = args[:messages]
        else
          message_container = Llm::MessageContainer.new
          message_container.add_raw_messages(args[:messages])
        end

        i = 0
        while (i += 1) < 20
          ret = self.chat(parameters: args.merge({
                                                   messages: message_container.to_capped_messages,
                                                   functions: args[:functions].map { |f| f.definition },
                                                 }))
          if ret.dig("choices", 0, "finish_reason") != 'function_call'
            break
          end

          # Function calling
          message = ret.dig("choices", 0, "message")
          function = args[:functions].detect { |f| f.function_name == message['function_call']['name'].to_sym }
          message_container.add_raw_message(message.merge({ content: nil }))

          function_args = (JSON.parse(message.dig('function_call', 'arguments')) || {}).with_indifferent_access
          agent.say(function.function_name)
          agent.say(function_args, color: false)

          function_result = function.execute_and_generate_message(function_args)
          message_container.add_raw_message({
                                              role: "function",
                                              name: function.function_name,
                                              content: JSON.dump(function_result),
                                            })

          if function.stop_llm_call?
            chat_message_io.write(function_result)
            return chat_message_io
          end
        end

        # メッセージ表示
        if content = ret.dig("choices", 0, "message", "content")
          chat_message_io.write(content)
        else
          # エラー発生か、function callingの回数が多すぎる場合は、他エージェントに相談する
          functions = args[:functions].select { |f| [
            "switch_assignee",
            "report_bug",
          ].include?(f.function_name.to_s) }
          ret = self.chat(parameters: args.merge({
                                                   messages: message_container.to_capped_messages,
                                                   functions: functions.map { |f| f.definition },
                                                 }))
          if content = ret.dig("choices", 0, "message", "content")
            chat_message_io.write(content)
          else
            puts ret
            exit 1
          end
        end
        chat_message_io
      end
    end
  end
end
