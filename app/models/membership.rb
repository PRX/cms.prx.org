# encoding: utf-8

class Membership < BaseModel

  belongs_to :user, -> { with_deleted }, touch: true
  belongs_to :account, -> { with_deleted }, touch: true

  scope :approved, -> { where(approved: true) }
end
