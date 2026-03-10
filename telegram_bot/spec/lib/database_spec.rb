require 'spec_helper'

RSpec.describe Database do
  describe '.connect' do
    it 'establishes database connection' do
      expect { Database.connect }.not_to raise_error
      expect(ActiveRecord::Base.connected?).to be true
    end

    it 'uses DATABASE_URL if available' do
      allow(ENV).to receive(:[]).with('DATABASE_URL').and_return('postgresql://user:pass@localhost/test')
      expect(ActiveRecord::Base).to receive(:establish_connection).with('postgresql://user:pass@localhost/test')
      Database.connect
    end
  end
end

