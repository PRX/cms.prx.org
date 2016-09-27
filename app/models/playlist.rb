# encoding: utf-8

class Playlist < BaseModel

  acts_as_paranoid

  belongs_to :account

  has_many :playlist_sections, foreign_key: 'playlist_id'
  has_many :picks, through: :playlist_sections
  has_many :stories, through: :picks
  has_many :taggings, as: :taggable
  has_many :user_tags, through: :taggings

  default_scope { where(type: nil) }  # no portfolios
  scope :named, ->(name = nil) { where(name ? { path: name } : 'path IS NOT NULL') }

  def self.policy_class
    AccountablePolicy
  end
end
