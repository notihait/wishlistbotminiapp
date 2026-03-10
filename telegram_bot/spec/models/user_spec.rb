require 'spec_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires telegram_id' do
      user = build(:user, telegram_id: nil)
      expect(user).not_to be_valid
      expect(user.errors[:telegram_id]).to include("can't be blank")
    end

    it 'requires unique telegram_id' do
      create(:user, telegram_id: 123456789)
      user2 = build(:user, telegram_id: 123456789)
      expect(user2).not_to be_valid
      expect(user2.errors[:telegram_id]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'has many wishlists' do
      user = create(:user)
      wishlist1 = create(:wishlist, user: user)
      wishlist2 = create(:wishlist, user: user)

      expect(user.wishlists).to include(wishlist1, wishlist2)
    end

    it 'destroys wishlists when user is destroyed' do
      user = create(:user)
      create(:wishlist, user: user)

      expect { user.destroy }.to change { Wishlist.count }.by(-1)
    end
  end

  describe '.find_or_create_by_telegram_id' do
    it 'finds existing user' do
      user = create(:user, telegram_id: 123456789)
      found = User.find_or_create_by(telegram_id: 123456789)
      expect(found.id).to eq(user.id)
    end

    it 'creates new user if not found' do
      expect {
        User.find_or_create_by(telegram_id: 987654321) do |u|
          u.username = 'newuser'
          u.first_name = 'New'
          u.last_name = 'User'
        end
      }.to change { User.count }.by(1)
    end
  end
end

