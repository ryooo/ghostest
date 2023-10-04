module Llm
  module Functions
    class ReportBug < Base
      def function_name
        :report_bug
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              message: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.message"),
              },
            },
            required: [:message],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        puts(args['message'])
        exit 0
      end
    end
  end
end
