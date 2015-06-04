class ProducerPolicy < ApplicationPolicy
  alias_method :producer, :record

  def create?
    update?
  end

  def update?
    user &&
      (producer.user == user ||
       AccountablePolicy.new(user, producer.story).update?)
  end
end
