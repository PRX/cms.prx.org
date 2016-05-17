# encoding: utf-8

class Pick < BaseModel

  self.table_name = 'playlistings'

  belongs_to :story, foreign_key: 'playlistable_id'
  belongs_to :playlist_section, touch: true

  has_one :playlist, through: :playlist_section
  has_one :account, through: :playlist_section

  # we only want picks from named playlists for now
  scope :named_playlists, -> { joins(:playlist).merge(Playlist.named).order(updated_at: :desc) }

  def self.policy_class
    AccountablePolicy
  end
end
