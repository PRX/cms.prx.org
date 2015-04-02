# encoding: utf-8

class Address < BaseModel

  belongs_to :addressable, polymorphic: true

  def account
    if addressable.is_a?(Account)
      addressable
    elsif addressable.is_a?(User)
      addressable.individual_account
    end
  end
end
