# encoding: utf-8
require 'hash_serializer'

class Distribution < BaseModel
  belongs_to :distributable, polymorphic: true, touch: true
  has_many :story_distributions
  serialize :properties, HashSerializer

  def owner
    distributable
  end

  def account
    if owner.is_a?(Account)
      owner
    else
      owner.try(:account)
    end
  end
end
