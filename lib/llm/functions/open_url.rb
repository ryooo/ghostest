module Llm
  module Functions
    class OpenUrl < Base
      def function_name
        :open_url
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              url: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.url"),
              },
              what_i_want_to_know: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.what_i_want_to_know"),
              },
            },
            required: [:url, :what_i_want_to_know],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        if args[:url].nil? || args[:url].empty?
          raise "url is required"
        end

        charset = nil
        html = URI.open(Addressable::URI.parse(args[:url]).display_uri.to_s) do |f|
          charset = f.charset
          f.read
        end
        page = Nokogiri::HTML.parse(html, nil, charset)
        html_page = HTMLPage.new(contents: (page.at_css('body').send(:inner_html) || page.inner_html))
        page_contents = html_page.markdown
        if page_contents.size > 25_000
          splitter = Baran::MarkdownSplitter.new(chunk_size: 25_000, chunk_overlap: 128)
          chunks = splitter.chunks(page_contents)

          summaries = []
          azure_open_ai = Llm::Clients::AzureOpenAi.new
          chunks.each do |chunk|
            ret = azure_open_ai.chat(parameters: {
              messages: [
                {
                  role: "system",
                  content: I18n.t("ghostest.functions.#{self.function_name}.summary_system", purpose: @purpose),
                },
                {
                  role: "user",
                  content: chunk[:text],
                },
              ],
            })
            summary = ret.dig("choices", 0, "message", "content")
            if summary.nil?
              raise "Azure OpenAI failed to summarize the content"
            end
            summaries << summary
          end
          page_contents = summaries.join("\n\n")
        end

        {
          url: args[:url],
          title: page.title,
          page_content: page_contents,
        }
      end
    end
  end
end
