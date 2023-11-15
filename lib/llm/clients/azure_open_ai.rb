module Llm
  module Clients
    class AzureOpenAi < Llm::Clients::Base
      def initialize(timeout: 30000)
        @client = OpenAI::Client.new(
          api_type: :azure,
          api_version: ENV.fetch("AZURE_API_VERSION"),
          access_token: ENV.fetch("AZURE_OPENAI_API_KEY"),
          uri_base: "#{ENV.fetch("AZURE_API_BASE")}/openai/deployments/#{ENV.fetch("AZURE_DEPLOYMENT_NAME")}",
          request_timeout: timeout,
        )
      end
    end
  end
end
