require 'spec_helper'

RSpec.describe Wishlist, type: :model do
  describe 'validations' do
    it 'requires name' do
      wishlist = build(:wishlist, name: nil)
      expect(wishlist).not_to be_valid
      expect(wishlist.errors[:name]).to include("can't be blank")
    end

    it 'requires event_date' do
      wishlist = build(:wishlist, event_date: nil)
      expect(wishlist).not_to be_valid
      expect(wishlist.errors[:event_date]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      user = create(:user)
      wishlist = create(:wishlist, user: user)
      expect(wishlist.user).to eq(user)
    end
  end

  describe 'scopes' do
    it 'can find wishlists by date range' do
      user = create(:user)
      today = Date.today
      past_wishlist = create(:wishlist, user: user, event_date: today - 5.days)
      today_wishlist = create(:wishlist, user: user, event_date: today)
      future_wishlist = create(:wishlist, user: user, event_date: today + 5.days)

      upcoming = Wishlist.where(event_date: today..(today + 7))
      expect(upcoming).to include(today_wishlist, future_wishlist)
      expect(upcoming).not_to include(past_wishlist)
    end
  end
end

