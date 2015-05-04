# encoding: utf-8

class Purchase < BaseModel
  belongs_to :purchased, class_name: 'Story'
  belongs_to :purchaser, -> { with_deleted }, class_name: 'User'
  belongs_to :purchaser_account, -> { with_deleted }, class_name: 'Account'
  belongs_to :seller_account, -> { with_deleted }, class_name: 'Account'
end
