require 'spec_helper'

module Llm
  module Agents
    RSpec.describe Reviewer do
      let(:logger) { instance_double('Logger') }
      let(:config) { instance_double('Ghostest::Config', agents: { 'Mr_reviewer' => instance_double('Ghostest::Config::Agent') }) }
      let(:name) { 'Mr_reviewer' }
      let(:reviewer) { described_class.new(name, config, logger) }

      describe '#initialize' do
        it 'initializes a Reviewer instance correctly' do
          expect(reviewer).to be_a(described_class)
          expect(reviewer.instance_variable_get(:@record_lgtm_function)).to be_a(Llm::Functions::RecordLgtm)
        end

        it 'initializes with the correct arguments' do
          expect(reviewer.instance_variable_get(:@name)).to eq(name)
          expect(reviewer.instance_variable_get(:@config)).to eq(config)
          expect(reviewer.instance_variable_get(:@logger)).to eq(logger)
        end
      end

      describe '#lgtm?' do
        let(:record_lgtm_function) { instance_double('Llm::Functions::RecordLgtm') }

        before do
          allow(Llm::Functions::RecordLgtm).to receive(:new).and_return(record_lgtm_function)
          allow(record_lgtm_function).to receive(:lgtm?)
        end

        it 'calls the lgtm? method on the record_lgtm_function instance variable' do
          reviewer.lgtm?
          expect(record_lgtm_function).to have_received(:lgtm?)
        end

        it 'returns the correct result when lgtm? is called' do
          allow(record_lgtm_function).to receive(:lgtm?).and_return(true)
          expect(reviewer.lgtm?).to eq(true)
        end
      end
    end
  end
end
