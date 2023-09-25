module Ghostest
  module Languages
    class Ruby
      def self.convert_source_path_to_test_path(source_path)
        # .rbで終わるファイルパスを前提とする
        "spec/#{source_path}".gsub(/\.rb$/, '_spec.rb')
      end

      def self.test_condition_yml_path
        "spec/ghostest_condition.yml"
      end

      def self.create_functions
        [
          Llm::Functions::ExecRspecTest.new,
          Llm::Functions::GetGemFilesList.new,
        ]
      end
    end
  end
end
