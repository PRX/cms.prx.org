# encoding: utf-8

class Authorization
  include RepresentedModel

  def initialize(user)
    @user = user
  end

  def id
    @user.id
  end

  def name
    @user.name
  end

  def accounts
    @user.approved_accounts.active
  end

  def default_account
    @user.default_account
  end
end
