# encoding: utf-8

class Network < BaseModel
  belongs_to :account
  has_many :pieces
end
