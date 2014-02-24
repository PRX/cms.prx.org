# encoding: utf-8

class Account < PRXModel

  has_many :stories
  # belongs_to :opener, class_name: 'User', foreign_key: 'opener_id', with_deleted: true
  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'AccountImage'
  belongs_to :opener, class_name: 'User', foreign_key: 'opener_id', with_deleted: true

  acts_as_paranoid

  scope :pending, -> { where status: :pending }
  scope :active, -> { where status: :open }

end
