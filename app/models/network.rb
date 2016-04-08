# encoding: utf-8

class Network < BaseModel
  belongs_to :account
  has_many :network_pieces
  has_many :pieces, through: :network_pieces
end
