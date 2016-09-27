class NetworkMembershipPolicy < ApplicationPolicy
  def create?
    update?
  end

  # create or update by network owner account admin
  def update?
    token && token.authorized?(resource.network.account.id, :admin)
  end

  # destroy by network owner account admin, or by network member account admin
  def destroy?
    token && (
      token.authorized?(resource.network.account.id, :admin) ||
      token.authorized?(resource.account.id, :admin)
    )
  end
end
