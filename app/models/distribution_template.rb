# encoding: utf-8

class DistributionTemplate < BaseModel
  belongs_to :distribution
  belongs_to :audio_version_template

  validate :same_series

  def same_series
    if distribution.distributable &&
       audio_version_template.series &&
       distribution.distributable != audio_version_template.series
      errors.add(:audio_version_template, 'must be in the same series')
    end
  end

  def account
    distribution.try(:account)
  end

  def distributable
    distribution&.distributable
  end

  def self.policy_class
    DistributablePolicy
  end
end
