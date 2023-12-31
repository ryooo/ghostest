module Llm
  class MessageContainer
    attr_reader :messages
    def initialize
      @messages = []
      @metas = []
      @token_encoder = Tiktoken.get_encoding("cl100k_base")

      self.add_default_system_message!
    end

    def add_system_message(content)
      @metas << { index: @metas.size, token: @token_encoder.encode(content.to_s).size, role: :system }
      @messages << { role: :system, content: }
    end

    def add_user_message(content)
      @metas << { index: @metas.size, token: @token_encoder.encode(content.to_s).size, role: :user }
      @messages << { role: :user, content: }
    end

    def add_raw_message(message)
      message = message.with_indifferent_access
      @metas << { index: @metas.size, token: @token_encoder.encode(message[:content].to_s).size, role: message[:role] }
      @messages << message
    end

    def total_token
      @metas.map { |meta| meta[:token] }.sum
    end

    def add_raw_messages(messages)
      messages.each do |message|
        self.add_raw_message(message)
      end
    end

    def to_capped_messages(token_limit: 28_000)
      return @messages if self.total_token <= token_limit

      # システムメッセージは消さない
      system_metas, not_system_metas = @metas.partition { |message| message[:role] == :system }
      current_token = system_metas.map { |meta| meta[:token] }.sum
      filtered_indexes = system_metas.map { |meta| meta[:index] }

      # 新しいメッセージを優先的に残す
      not_system_metas.reverse.each do |meta|
        break if token_limit < current_token + meta[:token]

        current_token += meta[:token]
        filtered_indexes << meta[:index]
      end

      # システムメッセージが挟み込まれている場合も、並び順を維持すること
      @messages.select.with_index { |message, i| filtered_indexes.include?(i) }
    end

    def add_default_system_message!
      self.add_system_message("Current time is #{Time.now}")
    end
  end

end
