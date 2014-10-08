class StoryPolicy < ApplicationPolicy
  attr_reader :user, :story

  def initialize(user, story)
    @user = user
    @story = story
  end

  def update?
    user && user.approved_accounts.include?(story.account)
  end
end
