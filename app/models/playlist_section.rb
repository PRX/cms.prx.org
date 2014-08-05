# encoding: utf-8

class PlaylistSection < BaseModel

  self.table_name = 'playlist_sections'

  belongs_to :playlist
  has_many :picks
  has_one :account, through: :playlist

end
