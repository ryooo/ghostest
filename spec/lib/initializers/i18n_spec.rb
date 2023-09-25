require 'spec_helper'

RSpec.describe 'I18n initializer' do
  let(:locales_dir) { File.expand_path('config/locales') }
  let(:yml_files) { Dir[locales_dir + '/**/*.yml'] }

  it 'adds all yml files in the locales directory to the I18n load path' do
    expect(I18n.load_path).to include(*yml_files)
  end

  it 'defines the just_raise_that_exception method on the I18n module' do
    expect(I18n).to respond_to(:just_raise_that_exception)
  end

  it 'sets the exception_handler for I18n to the just_raise_that_exception method' do
    expect(I18n.exception_handler).to eq(:just_raise_that_exception)
  end

  it 'raises an exception with a message including the argument when just_raise_that_exception is called' do
    expect { I18n.just_raise_that_exception('test') }.to raise_error('i18n: test')
  end
end
