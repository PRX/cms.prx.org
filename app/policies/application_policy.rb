class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    update?
  end
end
