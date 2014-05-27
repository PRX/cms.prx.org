# encoding: utf-8

class Pick < BaseModel

  self.table_name = 'playlistings'

  default_scope { joins(:playlist).merge(Playlist.named).order(updated_at: :desc) }  # we only want picks from named playlists for now

  belongs_to :playlist_section
  has_one :playlist, :through => :playlist_section
  belongs_to :story, :foreign_key => 'playlistable_id'
  has_one :account, :through => :playlist_section

end
