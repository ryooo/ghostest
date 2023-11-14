require 'spec_helper'

RSpec.describe Llm::Functions::GetFilesList do
  describe '#function_name' do
    it 'returns :get_files_list' do
      expect(subject.function_name).to eq :get_files_list
    end
  end

  describe '#definition' do
    it 'returns a hash with the correct keys and values' do
      definition = subject.definition
      expect(definition).to be_a(Hash)
      expect(definition[:name]).to eq :get_files_list
      expect(definition[:description]).to eq I18n.t("ghostest.functions.get_files_list.description")
      expect(definition[:parameters]).to eq({ type: :object, properties: {} })
    end
  end

  describe '#execute_and_generate_message' do
    before do
      @current_dir = Dir.pwd
      @test_dir = File.join(@current_dir, 'spec/dummy/get_files_list')
      FileUtils.mkdir_p(@test_dir)
      Dir.chdir(@test_dir)
    end

    after do
      Dir.chdir(@current_dir)
      FileUtils.rm_rf(@test_dir)
    end

    it 'returns a list of all .rb and .yml files in the current directory and its subdirectories' do
      FileUtils.touch('test.rb')
      FileUtils.touch('test.yml')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to include('test.rb')
      expect(files_list[:files_list]).to include('test.yml')
    end

    it 'excludes files that do not have .rb or .yml extensions' do
      FileUtils.touch('test.txt')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).not_to include('test.txt')
    end

    it 'includes .rb and .yml files in nested directories' do
      FileUtils.mkdir_p('nested_dir')
      FileUtils.touch('nested_dir/test.rb')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to include('nested_dir/test.rb')
    end

    it 'returns an empty list when the current directory and its subdirectories do not contain any .rb or .yml files' do
      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to be_empty
    end
  end
end
