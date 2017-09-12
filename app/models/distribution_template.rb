# encoding: utf-8

class DistributionTemplate < BaseModel
  belongs_to :distribution
  belongs_to :audio_version_template

  def account
    distribution.try(:account)
  end

  def self.policy_class
    AccountablePolicy
  end
end
