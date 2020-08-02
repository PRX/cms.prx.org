class ProducerPolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    token &&
      (resource.user.id == token.user_id ||
       AccountablePolicy.new(token, resource.story, :story).update?)
  end
end
