module Llm
  module Functions
    class FixOneRspecTest < Base
      def function_name
        :fix_one_rspec_test
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              file_path: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.file_path"),
              },
              line_num: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.line_num"),
              },
            },
            required: [:file_path, :line_num],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        if args[:file_path].nil? || args[:file_path].empty? || !File.exist?(args[:file_path])
          raise Ghostest::Error.new("Please specify the file path.")
        end
        line_num = args[:line_num].to_i
        if line_num < 1
          raise Ghostest::Error.new("Please specify the line num. #{args[:line_num]}")
        end

        n = 0
        while n < 5
          n += 1
          script = "bundle exec rspec '#{args['file_path']}:#{args['line_num']}'"
          stdout, stderr, status = Open3.capture3(script)
          if status.exitstatus != 0

          end
        end

        { stdout:, stderr:, exit_status: status.exitstatus }
      end
    end
  end
end
