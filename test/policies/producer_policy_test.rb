require 'test_helper'

describe ProducerPolicy do
  let(:user) { build_stubbed(:user) }
  let(:producer) { build_stubbed(:producer_with_user_and_story) }
  let(:story) { producer.story }

  describe '#update?' do
    it 'returns true if user is the producer' do
      ProducerPolicy.new(producer.user, producer).must_allow :update?
    end

    it 'returns true if user is associated with story' do
      user.stub(:approved_accounts, [story.account]) do
        ProducerPolicy.new(user, producer).must_allow :update?
      end
    end

    it 'returns false otherwise' do
      ProducerPolicy.new(user, producer).wont_allow :update?
    end
  end
end
