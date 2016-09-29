require 'test_helper'

describe ProducerPolicy do
  let(:producer_token) { StubToken.new(story.account_id + 1, ['member']) }
  let(:member_token) { StubToken.new(story.account_id, ['member']) }
  let(:non_member_token) { StubToken.new(story.account_id + 1, ['no']) }
  let(:producer) { build_stubbed(:producer_with_user_and_story, user: user, story: story) }
  let(:story) { build_stubbed(:story, account: account) }
  let(:account) { build_stubbed(:account) }
  let(:user) { build_stubbed(:user, id: producer_token.user_id) }

  describe '#update? and #create?' do
    it 'returns true if user is the producer' do
      ProducerPolicy.new(producer_token, producer).must_allow :update?
      ProducerPolicy.new(producer_token, producer).must_allow :create?
    end

    it 'returns true if user is associated with story' do
      ProducerPolicy.new(member_token, producer).must_allow :update?
      ProducerPolicy.new(member_token, producer).must_allow :create?
    end

    it 'returns false otherwise' do
      ProducerPolicy.new(non_member_token, producer).wont_allow :update?
      ProducerPolicy.new(non_member_token, producer).wont_allow :create?
    end
  end
end
