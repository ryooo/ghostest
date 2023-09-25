module Llm
  module Functions
    class OverwriteFile < Base
      def function_name
        :overwrite_file
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              filepath: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.filepath"),
              },
              new_text: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.new_text"),
              },
            },
            required: [:filepath, :new_text],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        unless File.exist?(args[:filepath])
          raise Ghostest::Error.new("File not found: #{args[:filepath]}")
        end
        File.write(args[:filepath], args[:new_text])

        { result: :success }
      end
    end
  end
end
