module Llm
  module Functions
    class GetGemFilesList < Base
      def function_name
        :get_gem_files_list
      end

      def self.gem_name_enums
        @gem_name_enums ||= ::Bundler.locked_gems.specs.map(&:full_name)
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              gem_name: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.gem_name"),
                enum: self.class.gem_name_enums,
              },
            },
            required: [:gem_name],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        unless self.class.gem_name_enums.include?(args['gem_name'])
          return { message: 'invalid gem_name. gem_name is below' + self.class.gem_name_enums.join("\n") }
        end
        files_list = Dir.glob("#{Gem.paths.home}/gems/#{args['gem_name']}/**/*.{rb,yml}")

        { files_list: }
      end
    end
  end
end
