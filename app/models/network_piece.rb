# encoding: utf-8

class NetworkPiece < BaseModel
  belongs_to :piece
  belongs_to :network
end
