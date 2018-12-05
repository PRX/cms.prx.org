class AccountPolicy < ApplicationPolicy
  def create?
    token && token.authorized?(ENV['PRX_ADMIN_ID'], :admin)
  end

  def update?
    token && token.authorized?(resource.id)
  end

  def destroy?
    token && token.authorized?(resource.id, :admin)
  end
end
