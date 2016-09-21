# encoding: utf-8

class PlaylistSection < BaseModel
  self.table_name = 'playlist_sections'

  belongs_to :playlist, touch: true

  has_many :picks
  has_many :stories, through: :picks

  has_one :account, through: :playlist

  def self.policy_class
    AccountablePolicy
  end
end
