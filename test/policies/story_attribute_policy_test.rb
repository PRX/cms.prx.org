require 'test_helper'

describe StoryAttributePolicy do
  describe '#update?' do
    let(:member_token) { StubToken.new(story.account_id, ['cms:story']) }
    let(:n_m_token) { StubToken.new(story.account_id + 1, ['cms:story']) }
    let(:n_s_token) { StubToken.new(story.account_id, ['cms:member']) }
    let(:story) { build(:story) }
    let(:musical_work) { build(:musical_work, story: story) }

    it 'returns true if user is a member of story account' do
      StoryAttributePolicy.new(member_token, musical_work).must_allow :update?
      StoryAttributePolicy.new(member_token, musical_work).must_allow :create?
    end

    it 'returns false if user is not present' do
      StoryAttributePolicy.new(nil, musical_work).wont_allow :update?
      StoryAttributePolicy.new(nil, musical_work).wont_allow :create?
    end

    it 'returns false if user is not a member of story account' do
      StoryAttributePolicy.new(n_m_token, musical_work).wont_allow :update?
      StoryAttributePolicy.new(n_m_token, musical_work).wont_allow :create?
    end

    it 'returns false if token does not have story permission for referenced account' do
      StoryAttributePolicy.new(n_s_token, musical_work).wont_allow :update?
      StoryAttributePolicy.new(n_s_token, musical_work).wont_allow :create?
    end

    describe 'with a draft token' do
      it 'returns true if token has story-draft and story is a draft'
      it 'returns false if token has story-draft but story is published'
      it 'returns false if token lacks story-draft and story is a draft'
    end
  end
end
