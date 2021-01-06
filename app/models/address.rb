# encoding: utf-8

class Address < BaseModel
  belongs_to :addressable, -> { with_deleted }, polymorphic: true, touch: true

  def account_id
    if addressable_type == 'Account'
      addressable_id
    elsif addressable_type == 'User'
      # warning: this will load things
      addressable.individual_account.try(:id)
    end
  end

  def account
    if addressable.is_a?(Account)
      addressable
    elsif addressable.is_a?(User)
      addressable.individual_account
    end
  end

  def account=(a)
    self.addressable = a
  end

  def self.policy_class
    AccountablePolicy
  end
end
