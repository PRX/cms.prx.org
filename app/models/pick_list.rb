# encoding: utf-8

class PickList < BaseModel
  acts_as_paranoid

  self.table_name = 'playlists'

  has_many :playlist_sections, :foreign_key => 'playlist_id'
  has_many :picks, :through => :playlist_sections
  belongs_to :account

end
