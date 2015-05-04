# encoding: utf-8

class Membership < BaseModel

  belongs_to :user, -> { with_deleted }
  belongs_to :account, -> { with_deleted }

  scope :approved, -> { where(approved: true) }
end
