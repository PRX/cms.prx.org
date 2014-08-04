# encoding: utf-8

class Website < BaseModel
  belongs_to :browsable, polymorphic: true

  SEARCH  = /^(?!http)./
  REPLACE = 'http://\\0'

  def url
    super.sub(SEARCH, REPLACE)
  end

  def as_link
    { href: url }
  end
end
