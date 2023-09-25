require 'spec_helper'

RSpec.describe Llm::MessageContainer do
  let(:message_container) { Llm::MessageContainer.new }

  describe '#initialize' do
    it 'initializes @messages, @metas, @token_encoder and calls add_default_system_message!' do
      expect(message_container.messages).to eq([{ role: :system, content: "Current time is #{Time.now}" }])
    end
  end

  describe '#add_system_message' do
    it 'adds a system message to @messages and correct metadata to @metas' do
      message_container.add_system_message('Test system message')
      expect(message_container.messages).to include({ role: :system, content: 'Test system message' })
    end
  end

  describe '#add_user_message' do
    it 'adds a user message to @messages and correct metadata to @metas' do
      message_container.add_user_message('Test user message')
      expect(message_container.messages).to include({ role: :user, content: 'Test user message' })
    end
  end

  describe '#add_raw_message' do
    it 'adds a raw message to @messages and correct metadata to @metas' do
      message_container.add_raw_message({ role: :user, content: 'Test raw message' })
      expect(message_container.messages).to include({ role: :user, content: 'Test raw message' })
    end
  end

  describe '#total_token' do
    it 'returns the correct total token count' do
      message_container.add_raw_message({ role: :user, content: 'Test raw message' })
      expect(message_container.total_token).to be > 0
    end
  end

  describe '#add_raw_messages' do
    it 'adds multiple raw messages correctly' do
      messages = [
        { role: :user, content: 'Test raw message 1' },
        { role: :system, content: 'Test raw message 2' },
      ]
      message_container.add_raw_messages(messages)
      expect(message_container.messages).to include(*messages)
    end
  end

  describe '#to_capped_messages' do
    context 'when total token count is less than or equal to token limit' do
      it 'returns the same @messages' do
        expect(message_container.to_capped_messages(token_limit: 28_000)).to eq(message_container.messages)
      end
    end

    context 'when total token count is more than token limit' do
      it 'returns the correct @messages' do
        5000.times { message_container.add_raw_message({ role: :user, content: 'Test raw message' }) }
        expect(message_container.to_capped_messages(token_limit: 28_000).size).to be <= message_container.messages.size
      end
    end
  end

  describe '#add_default_system_message!' do
    it 'adds a default system message correctly' do
      message_container = Llm::MessageContainer.new
      expect(message_container.messages).to eq([{ role: :system, content: "Current time is #{Time.now}" }])
    end
  end
end
