# encoding: utf-8

class Account < BaseModel
  acts_as_paranoid

  belongs_to :opener, class_name: 'User', foreign_key: 'opener_id', with_deleted: true

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'AccountImage'

  has_many :stories, -> { where('published_at is not null and network_only_at is null').order(published_at: :desc) }
  has_many :memberships

  scope :pending, -> { where status: :pending }
  scope :active, -> { where status: :open }
  scope :member,  -> { where type: ['StationAccount', 'GroupAccount'] }

end
