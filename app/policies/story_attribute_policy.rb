class StoryAttributePolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update?
    StoryPolicy.new(user, record.story).update
  end
end
