class ProducerPolicy < ApplicationPolicy
  attr_reader :user, :producer

  def initialize(user, producer)
    @user = user
    @producer = producer
  end

  def create?
    update?
  end

  def update?
    user &&
      (producer.user == user ||
       AccountablePolicy.new(user, producer.story).update?)
  end
end
