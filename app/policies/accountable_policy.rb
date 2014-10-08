module AccountablePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    user && !user.approved_accounts.empty?
  end

  def update?
    user && user.approved_accounts.include?(record.account)
  end
end
