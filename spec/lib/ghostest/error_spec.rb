require 'spec_helper'

RSpec.describe Ghostest::Error do
  it 'is a kind of StandardError' do
    expect(Ghostest::Error.new).to be_a_kind_of StandardError
  end

  it 'can be raised and rescued' do
    begin
      raise Ghostest::Error
    rescue Ghostest::Error
      expect($!).to be_a_kind_of Ghostest::Error
    end
  end

  it 'can accept a custom error message when it is raised' do
    custom_message = 'This is a custom error message'
    begin
      raise Ghostest::Error, custom_message
    rescue Ghostest::Error
      expect($!.message).to eq custom_message
    end
  end
end
