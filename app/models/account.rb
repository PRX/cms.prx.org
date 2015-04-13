# encoding: utf-8

class Account < BaseModel
  acts_as_paranoid

  belongs_to :opener, class_name: 'User', foreign_key: 'opener_id', with_deleted: true

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'AccountImage'
  has_one :portfolio

  has_many :stories, -> { where('published_at is not null and network_only_at is null').order(published_at: :desc) }
  has_many :memberships
  has_many :websites, as: :browsable
  has_many :playlists

  scope :pending, -> { where status: :pending }
  scope :active, -> { where status: :open }
  scope :member, -> { where type: ['StationAccount', 'GroupAccount'] }

  def short_name
    name
  end

  def portfolio_stories
    portfolio ? portfolio.stories.order(published_at: :desc) : Kaminari.paginate_array([])
  end

  def self.policy_class
    AccountPolicy
  end
end
