# encoding: utf-8

class IndividualAccount < Account
  def name
    opener.try(:name)
  end

  def short_name
    opener.try(:first_name)
  end

  def path
    opener.try(:login)
  end

  def image
    opener.try(:image)
  end

  def address
    opener.try(:address)
  end

  def description
    opener.try(:bio)
  end

  def self.policy_class
    IndividualAccountPolicy
  end
end
