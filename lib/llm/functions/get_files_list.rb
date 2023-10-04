module Llm
  module Functions
    class GetFilesList < Base
      def function_name
        :get_files_list
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {},
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        files_list = Dir.glob("**/*.{rb,yml}")

        { files_list: }
      end
    end
  end
end
