require 'test_helper'

describe StoryAttributePolicy do
  describe '#update?' do
    let(:user) { build_stubbed(:user) }
    let(:user2) { build_stubbed(:user) }
    let(:story) { build_stubbed(:story) }
    let(:musical_work) { build_stubbed(:musical_work, story: story) }

    it 'returns true if user is a member of story account' do
      user.stub(:approved_accounts, [story.account]) do
        StoryAttributePolicy.new(user, musical_work).must_allow :update?
      end
    end

    it 'returns false if user is not present' do
      StoryAttributePolicy.new(user, musical_work).wont_allow :update?
    end

    it 'returns false if user is not a member of story account' do
      user.stub(:approved_accounts, []) do
        StoryAttributePolicy.new(user2, musical_work).wont_allow :update?
      end
    end
  end
end
