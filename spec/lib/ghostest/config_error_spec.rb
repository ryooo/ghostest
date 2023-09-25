require 'spec_helper'

RSpec.describe Ghostest::ConfigError do
  it 'is a subclass of StandardError' do
    expect(described_class).to be < StandardError
  end
end
