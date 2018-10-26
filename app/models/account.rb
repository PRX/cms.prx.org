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

  validate :path_is_present, :path_is_right_length, :path_is_right_format, :path_is_not_reserved, :path_is_unique

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
    return unless self[:path] && path_changed?
    errors.add(:path, 'has already been taken') if ROUTE_RESERVED_WORDS.include?(self[:path].downcase)
  end

  def path_is_unique
    return unless self[:path] && path_changed?
    errors.add(:path, 'has already been taken') if Account.find_by(path: self[:path])
  end

  def path_is_present
    errors.add(:path, 'can\'t be blank') unless self[:path]
  end

  def path_is_right_length
    return unless self[:path] && path_changed?
    (pathmin, pathmax) = [1, 40]
    errors.add(:path, "is too short (minimum is #{pathmin} #{'character'.pluralize(pathmin)})") if self[:path].length < pathmin
    errors.add(:path, "is too long (maximum is #{pathmax} #{'character'.pluralize(pathmax)})") if self[:path].length > pathmax
  end

  def path_is_right_format
    return unless self[:path] && path_changed?
    errors.add(:path, "is invalid. Must be only letters, numbers, '-' and '_'") unless self[:path].match /\A[A-Za-z\d_-]+\z/
  end
end
