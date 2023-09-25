require 'spec_helper'

RSpec.describe Ghostest::TestCondition do
  let(:language_klass) { Ghostest::Languages::Ruby }
  let(:test_condition) { described_class.new(language_klass) }
  let(:source_path) { 'spec/dummy/source.rb' }
  let(:test_path) { 'spec/dummy/test.rb' }
  let(:test_condition_yml_path) { 'spec/dummy/ghostest_condition.yml' }

  before do
    allow(language_klass).to receive(:test_condition_yml_path).and_return(test_condition_yml_path)
    allow(language_klass).to receive(:convert_source_path_to_test_path).with(source_path).and_return(test_path)
  end

  describe '#initialize' do
    it 'creates a new TestCondition object with the given language class' do
      expect(test_condition.instance_variable_get(:@language_klass)).to eq(language_klass)
    end

    it 'creates a new test condition YAML file if it does not exist' do
      File.delete(test_condition_yml_path) if File.exist?(test_condition_yml_path)
      expect { described_class.new(language_klass) }.to change { File.exist?(test_condition_yml_path) }.from(false).to(true)
    end

    it 'loads the test conditions from the YAML file into the @test_condition instance variable' do
      File.write(test_condition_yml_path, { test_path => { source_md5: 'dummy_md5' } }.to_yaml)
      expect(described_class.new(language_klass).instance_variable_get(:@test_condition)).to eq({ test_path => { source_md5: 'dummy_md5' } })
    end
  end

  describe '#save_as_updated!' do
    it 'saves the MD5 hash of the source file contents to the test condition YAML file' do
      File.delete(test_condition_yml_path) if File.exist?(test_condition_yml_path)
      File.write(source_path, 'dummy_content')
      test_condition.instance_variable_set(:@test_condition, {})
      expect { test_condition.save_as_updated!(source_path) }.to change { YAML.load_file(test_condition_yml_path)[source_path] }.from(nil).to({ source_md5: Digest::MD5.hexdigest('dummy_content') })
    end

    it 'updates the @test_condition instance variable with the new test condition' do
      File.write(source_path, 'dummy_content')
      test_condition.instance_variable_set(:@test_condition, {})
      expect { test_condition.save_as_updated!(source_path) }.to change { test_condition.instance_variable_get(:@test_condition)[source_path] }.from(nil).to({ source_md5: Digest::MD5.hexdigest('dummy_content') })
    end
  end

  describe '#should_update_test?' do
    before do
      File.write(source_path, 'dummy_content')
      test_condition.save_as_updated!(source_path)
    end

    it 'returns true if the MD5 hash of the source file contents is different from the one saved in the test condition YAML file' do
      File.write(source_path, 'updated_content')
      expect(test_condition.should_update_test?(source_path)).to eq(true)
    end

    it 'returns true if there is no entry for the test file in the test condition YAML file' do
      File.write(source_path, 'dummy_content')
      File.write(test_condition_yml_path, {}.to_yaml)
      test_condition.instance_variable_set(:@test_condition, {})
      expect(test_condition.should_update_test?(source_path)).to eq(true)
    end

    it 'returns false if the MD5 hash of the source file contents is the same as the one saved in the test condition YAML file' do
      expect(test_condition.should_update_test?(source_path)).to eq(false)
    end
  end
end
