# encoding: utf-8

class Address < BaseModel

  belongs_to :addressable, polymorphic: true

end
