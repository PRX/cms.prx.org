class AccountablePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    update?
  end

  def update?
    user && user.approved_accounts.include?(record.account)
  end

  def destroy?
    update?
  end
end
