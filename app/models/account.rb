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

  validates_format_of :path, with: /\A[A-Za-z\d_-]+\z/, unless: :individual_acct?
  validates_length_of :path, within: 1..40, unless: :individual_acct?
  validates_uniqueness_of :path, case_sensitive: false, unless: :individual_acct?
  validates_presence_of :path, unless: :individual_acct?
  validate :path_is_not_reserved, unless: :individual_acct?

  def short_name
    name
  end

  def portfolio_stories
    portfolio ? portfolio.stories.order(published_at: :desc) : Story.none
  end

  def self.policy_class
    AccountPolicy
  end

  private

  def individual_acct?
    type.eql?('IndividualAccount')
  end

  def path_is_not_reserved
    errors.add(:path, 'has already been taken') if path_changed? &&
                                                   ROUTE_RESERVED_WORDS.include?(path.downcase)
  end
end
