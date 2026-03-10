require 'spec_helper'
require_relative '../../lib/reminder_service'

RSpec.describe ReminderService do
  let(:bot) { double('Bot', api: double('API')) }
  let(:service) { ReminderService.new(bot) }
  let(:user) { create(:user, telegram_id: 123456789) }

  describe '#initialize' do
    it 'creates a scheduler' do
      expect(service.instance_variable_get(:@scheduler)).to be_a(Rufus::Scheduler)
    end
  end

  describe '#start' do
    it 'schedules daily check' do
      scheduler = service.instance_variable_get(:@scheduler)
      expect(scheduler).to receive(:cron).with('0 9 * * *')
      service.start
    end
  end

  describe '#check_upcoming_events' do
    before do
      allow(bot.api).to receive(:send_message)
    end

    context 'when event is today' do
      it 'sends reminder message' do
        wishlist = create(:wishlist, user: user, event_date: Date.today)
        
        expect(bot.api).to receive(:send_message).with(
          chat_id: user.telegram_id,
          text: "🎉 Сегодня событие: #{wishlist.name}!"
        )
        
        service.send(:check_upcoming_events)
      end
    end

    context 'when event is in 7 days' do
      it 'sends reminder message' do
        wishlist = create(:wishlist, user: user, event_date: Date.today + 7)
        
        expect(bot.api).to receive(:send_message).with(
          chat_id: user.telegram_id,
          text: "📅 Через неделю: #{wishlist.name} (#{wishlist.event_date.strftime('%d.%m.%Y')})"
        )
        
        service.send(:check_upcoming_events)
      end
    end

    context 'when event is in 3 days' do
      it 'sends reminder message' do
        wishlist = create(:wishlist, user: user, event_date: Date.today + 3)
        
        expect(bot.api).to receive(:send_message).with(
          chat_id: user.telegram_id,
          text: "⏰ Через 3 дня: #{wishlist.name} (#{wishlist.event_date.strftime('%d.%m.%Y')})"
        )
        
        service.send(:check_upcoming_events)
      end
    end

    context 'when event is in 1 day' do
      it 'sends reminder message with correct grammar' do
        wishlist = create(:wishlist, user: user, event_date: Date.today + 1)
        
        expect(bot.api).to receive(:send_message).with(
          chat_id: user.telegram_id,
          text: "⏰ Через 1 день: #{wishlist.name} (#{wishlist.event_date.strftime('%d.%m.%Y')})"
        )
        
        service.send(:check_upcoming_events)
      end
    end

    context 'when event is more than 7 days away' do
      it 'does not send reminder' do
        create(:wishlist, user: user, event_date: Date.today + 10)
        
        expect(bot.api).not_to receive(:send_message)
        service.send(:check_upcoming_events)
      end
    end

    context 'when event is in the past' do
      it 'does not send reminder' do
        create(:wishlist, user: user, event_date: Date.today - 1)
        
        expect(bot.api).not_to receive(:send_message)
        service.send(:check_upcoming_events)
      end
    end

    context 'with multiple users' do
      it 'sends reminders to all relevant users' do
        user2 = create(:user, telegram_id: 987654321)
        wishlist1 = create(:wishlist, user: user, event_date: Date.today)
        wishlist2 = create(:wishlist, user: user2, event_date: Date.today + 3)
        
        expect(bot.api).to receive(:send_message).with(
          chat_id: user.telegram_id,
          text: "🎉 Сегодня событие: #{wishlist1.name}!"
        )
        expect(bot.api).to receive(:send_message).with(
          chat_id: user2.telegram_id,
          text: "⏰ Через 3 дня: #{wishlist2.name} (#{wishlist2.event_date.strftime('%d.%m.%Y')})"
        )
        
        service.send(:check_upcoming_events)
      end
    end
  end

  describe '#stop' do
    it 'shuts down scheduler' do
      scheduler = service.instance_variable_get(:@scheduler)
      expect(scheduler).to receive(:shutdown)
      service.stop
    end
  end
end

