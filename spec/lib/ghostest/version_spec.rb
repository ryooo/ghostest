require 'spec_helper'

RSpec.describe 'Ghostest::VERSION' do
  it 'has a version number' do
    expect(Ghostest::VERSION).not_to be nil
  end

  it 'is a string' do
    expect(Ghostest::VERSION).to be_a(String)
  end

  it 'is in the correct format' do
    expect(Ghostest::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
