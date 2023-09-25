module Ghostest
  class TestCondition
    def initialize(language_klass)
      @language_klass = language_klass
      unless File.exist?(@language_klass.test_condition_yml_path)
        FileUtils.mkdir_p(File.dirname(@language_klass.test_condition_yml_path))
        File.write(@language_klass.test_condition_yml_path, YAML.dump({}))
      end
      @test_condition = YAML.load(File.read(@language_klass.test_condition_yml_path)) || {}
    end

    def save_as_updated!(source_path)
      source_md5 = Digest::MD5.hexdigest(File.read(source_path))
      @test_condition[source_path] = { source_md5: source_md5 }

      File.write(@language_klass.test_condition_yml_path, YAML.dump(@test_condition))
    end

    def should_update_test?(source_path)
      source_md5 = Digest::MD5.hexdigest(File.read(source_path))
      @test_condition[source_path].nil? || @test_condition[source_path][:source_md5] != source_md5
    end
  end
end
