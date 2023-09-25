require 'spec_helper'
require 'ghostest'

describe Ghostest do
  it 'loads without error' do
    expect { Ghostest }.not_to raise_error
  end
end
