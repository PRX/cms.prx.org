# encoding: utf-8

class NetworkMembership < BaseModel
  belongs_to :account
  belongs_to :network
end
