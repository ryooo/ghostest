require 'spec_helper'

RSpec.describe Llm::Functions::GetFilesList do
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

    it 'returns a list of all .rb and .yml files in the repository' do
      FileUtils.touch('test.rb')
      FileUtils.touch('test.yml')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to include('test.rb')
      expect(files_list[:files_list]).to include('test.yml')
    end

    it 'does not include files with other extensions' do
      FileUtils.touch('test.txt')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).not_to include('test.txt')
    end

    it 'includes files in nested directories' do
      FileUtils.mkdir_p('nested_dir')
      FileUtils.touch('nested_dir/test.rb')

      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to include('nested_dir/test.rb')
    end

    it 'returns an empty list when there are no .rb or .yml files' do
      files_list = subject.execute_and_generate_message({})

      expect(files_list[:files_list]).to be_empty
    end
  end
end
