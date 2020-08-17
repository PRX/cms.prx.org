require 'test_helper'

describe StoryPolicy do
  let(:token) { StubToken.new(account.id, ['cms:story']) }
  let(:account) { build_stubbed(:account) }
  let(:story) { build(:story, account: account) }
  let(:policy) { StoryPolicy.new(token, story) }


  describe 'with a full token' do
    it 'is allowed to #create?' do
      story.published_at = 13.days.ago
      policy.must_allow :create?
    end

    describe '#update?' do
      it 'is allowed' do
        story.published_at = 7.minutes.ago
        policy.must_allow :update?
      end

      it 'is not allowed when account_id was not controlled' do
        story.account_id = account.id + 1
        story.save

        story.account_id = account.id
        policy.wont_allow :update?
      end
    end

    it 'is allowed to #destroy?' do
      story.published_at = 12.seconds.from_now
    end

    it 'is allowed to #publish?' do
      policy.must_allow :publish?
    end

    it 'is allowed to #unpublish?' do
      policy.must_allow :unpublish?
    end
  end

  describe 'with draft token' do

    let(:token) { StubToken.new(account.id, ['cms:story-draft']) }

    describe '#create?' do
      it 'is allowed when story is a draft' do
        story.published_at = nil

        policy.must_allow :create?
      end

      it 'is not allowed when story is not a draft' do
        story.published_at = 10.days.from_now

        policy.wont_allow :create?
      end
    end

    describe '#update?' do
      it 'is allowed when story is a draft and was a draft' do
        story.published_at = nil
        story.save

        policy.must_allow :update?
      end

      it 'is not allowed when story was not a draft, even if it is now' do
        story.published_at = 14.seconds.ago
        story.save

        story.published_at = nil
        policy.wont_allow :update?
      end

      it 'is not allowed if story is not a draft' do
        story.published_at = 14.seconds.ago
        story.save

        policy.wont_allow :update?
      end

      it 'is not allowed when account_id was not controlled' do
        story.published_at = nil
        story.account_id = account.id + 1
        story.save

        story.account_id = account.id
        policy.wont_allow :update?
      end
    end

    describe '#destroy?' do
      it 'is allowed when story is a draft and was a draft' do
        story.published_at = nil
        story.save

        policy.must_allow :destroy?
      end

      it 'is not allowed if story is not a draft' do
        story.published_at = 10.years.ago
        story.save

        policy.wont_allow :destroy?
      end
    end
  
    describe '#publish?' do
      it 'is not allowed, even with draft story' do
        story.published_at = nil
        story.save

        policy.wont_allow :publish?
      end
    end
  
    describe '#unpublish?' do
      it 'is not allowed, even with draft story' do
        story.published_at = nil
        story.save

        policy.wont_allow :unpublish?
      end
    end
  end
end
