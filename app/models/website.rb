# encoding: utf-8

class Website < BaseModel
  belongs_to :browsable, polymorphic: true, touch: true

  SEARCH  = /^(?!http)./
  REPLACE = 'http://\\0'.freeze

  def url
    super.sub(SEARCH, REPLACE)
  end

  def as_link
    { href: url }
  end

  def owner
    browsable
  end

  def self.policy_class
    OwnedPolicy
  end
end
