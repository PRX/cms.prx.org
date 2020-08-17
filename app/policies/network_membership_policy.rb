class NetworkMembershipPolicy < ApplicationPolicy
  def create?
    update?
  end

  # create or update by network owner account admin
  def update?
    token&.authorized?(resource.network.account.id, :network_members)
  end

  # destroy by network owner account admin, or by network member account admin
  def destroy?
    token&.authorized?(resource.network.account.id, :network_members) ||
      token&.authorized?(resource.account.id, :network_members)
  end
end
