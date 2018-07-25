# encoding: utf-8

class Account < BaseModel
  include Storied

  acts_as_paranoid

  belongs_to :opener, -> { with_deleted }, class_name: 'User', foreign_key: 'opener_id'

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'AccountImage', dependent: :destroy
  has_one :portfolio

  has_many :stories, -> { order(published_at: :desc) }
  has_many :series
  has_many :memberships
  has_many :websites, as: :browsable
  has_many :playlists
  has_many :podcast_imports

  has_many :network_memberships
  has_many :networks, through: :network_memberships

  scope :pending, -> { where status: :pending }
  scope :active, -> { where status: :open }
  scope :member, -> { where type: ['StationAccount', 'GroupAccount'] }

  def short_name
    name
  end

  def portfolio_stories
    portfolio ? portfolio.stories.order(published_at: :desc) : Story.none
  end

  def self.policy_class
    AccountPolicy
  end
end
