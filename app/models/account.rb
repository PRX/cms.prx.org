# encoding: utf-8

class Account < PRXModel

  has_many :stories
  # belongs_to :opener, class_name: 'User', foreign_key: 'opener_id', with_deleted: true
  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'AccountImage'

  scope :pending, -> { where status: :pending }

end

# * Producing Account
#   * Name
#   * Username
#   * Location
#   * Photo
#   * Social Media Links
