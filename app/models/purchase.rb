# encoding: utf-8

class Purchase < BaseModel
  belongs_to :purchased, class_name: 'Story', touch: true
  belongs_to :purchaser, -> { with_deleted }, class_name: 'User', touch: true
  belongs_to :purchaser_account, -> { with_deleted }, class_name: 'Account', touch: true
  belongs_to :seller_account, -> { with_deleted }, class_name: 'Account', touch: true
end
