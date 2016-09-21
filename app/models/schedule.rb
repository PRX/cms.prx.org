# encoding: utf-8

class Schedule < BaseModel
  belongs_to :series

  def self.policy_class
    SeriesAttributePolicy
  end
end
