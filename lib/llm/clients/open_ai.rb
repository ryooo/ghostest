module Llm
  module Clients
    class OpenAi < Llm::Clients::Base
      def initialize(timeout: 300)
        @client = OpenAI::Client.new(
          api_version: ENV.fetch("OPENAI_API_VERSION"),
          access_token: ENV.fetch("OPENAI_API_KEY"),
          uri_base: "https://openai.com/openai/deployments/chat/completions",
          request_timeout: timeout,
        )
      end
    end
  end
end
