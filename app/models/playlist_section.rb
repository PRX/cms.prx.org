# encoding: utf-8

class PlaylistSection < BaseModel

  self.table_name = 'playlist_sections'

  belongs_to :pick_list, :foreign_key => 'playlist_id'
  has_many :picks
  has_one :account, :through => :pick_list

end

