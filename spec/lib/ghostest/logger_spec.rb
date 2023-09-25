require 'spec_helper'

RSpec.describe Ghostest::Logger do
  let(:logger) { described_class.instance }

  describe '#initialize' do
    it 'initializes with correct formatter and level' do
      expect(logger.formatter).to be_a(Proc)
      expect(logger.level).to eq(Logger::INFO)
    end
  end

  describe '#verbose' do
    context 'when @verbose is not set' do
      it 'returns false' do
        expect(logger.verbose).to eq(false)
      end
    end
  end

  describe '#verbose=' do
    it 'sets the value of @verbose' do
      logger.verbose = true
      expect(logger.verbose).to eq(true)
    end
  end

  describe '#verbose_info' do
    context 'when verbose is true' do
      it 'logs information' do
        logger.verbose = true
        expect(logger).to receive(:info).with("message")
        logger.verbose_info('message')
      end
    end

    context 'when verbose is false' do
      it 'does not log information' do
        logger.verbose = false
        allow(logger).to receive(:info)
        logger.verbose_info('message')
        expect(logger).not_to have_received(:info)
      end
    end
  end

  describe '#debug=' do
    context 'when value is true' do
      it 'sets the logger level to DEBUG' do
        logger.debug = true
        expect(logger.level).to eq(Logger::DEBUG)
      end
    end

    context 'when value is false' do
      it 'sets the logger level to INFO' do
        logger.debug = false
        expect(logger.level).to eq(Logger::INFO)
      end
    end
  end
end
