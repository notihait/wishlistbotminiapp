require 'spec_helper'
# Не загружаем bot.rb напрямую, так как он пытается подключиться к Telegram API
# require_relative '../bot'

RSpec.describe 'Bot Integration' do
  let(:token) { 'test_token' }
  let(:bot_instance) { double('Bot') }
  let(:api) { double('API') }

  before do
    allow(ENV).to receive(:[]).with('TELEGRAM_BOT_TOKEN').and_return(token)
    allow(Telegram::Bot::Client).to receive(:run).and_yield(bot_instance)
    allow(bot_instance).to receive(:api).and_return(api)
    allow(bot_instance).to receive(:listen).and_yield(message)
  end

  describe 'command handling' do
    let(:message) do
      double('Message',
        text: '/start',
        from: double('User', id: 123456789, username: 'testuser', first_name: 'Test', last_name: 'User'),
        chat: double('Chat', id: 123456789)
      )
    end

    it 'handles /start command' do
      expect(api).to receive(:send_message).with(
        chat_id: 123456789,
        text: /Привет, Test!/
      )

      # Мокируем выполнение бота
      allow(User).to receive(:find_or_create_by).and_return(double('User'))
      # Здесь можно добавить более детальное тестирование логики бота
    end
  end
end

