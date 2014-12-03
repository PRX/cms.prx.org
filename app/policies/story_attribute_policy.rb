class StoryAttributePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    update?
  end

  def update?
    AccountablePolicy.new(user, record.story).update?
  end
end
