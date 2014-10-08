class ProducerPolicy < ApplicationPolicy
  attr_reader :user, :producer

  def initialize(user, producer)
    @user = user
    @producer = producer
  end

  def update?
    user && (producer.user == user || StoryPolicy.new(user, producer.story).update?)
  end
end
