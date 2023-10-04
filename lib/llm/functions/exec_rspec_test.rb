module Llm
  module Functions
    class ExecRspecTest < Base
      def function_name
        :exec_rspec_test
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              file_or_dir_path: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.file_or_dir_path"),
              },
            },
            required: [:file_or_dir_path],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        if args[:file_or_dir_path].nil? || args[:file_or_dir_path].empty?
          raise Ghostest::Error.new("Please specify the file or directory path.")
        end
        script = "bundle exec rspec '#{args['file_or_dir_path']}'"
        stdout, stderr, status = Open3.capture3(script)

        { stdout:, stderr:, exit_status: status.exitstatus }
      end
    end
  end
end
