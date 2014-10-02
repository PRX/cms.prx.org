class StoryPolicy < ApplicationPolicy
  attr_reader :user, :story

  def initialize(user, story)
    @user = user
    @story = story
  end

  def update?
    user.accounts.include? story.account
  end
end
