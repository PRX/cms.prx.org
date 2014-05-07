# encoding: utf-8

class Pick < BaseModel

  self.table_name = 'playlistings'

  belongs_to :playlist_section
  has_one :pick_list, :through => :playlist_section
  belongs_to :story, :foreign_key => 'playlistable_id'
  has_one :account, :through => :playlist_section

end
