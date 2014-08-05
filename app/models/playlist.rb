# encoding: utf-8

class Playlist < BaseModel

  acts_as_paranoid

  belongs_to :account

  has_many :playlist_sections, foreign_key: 'playlist_id'
  has_many :picks, through: :playlist_sections

  default_scope { where(type: nil) }  # no portfolios
  scope :named, ->(name=nil) {
    if name
      where(path: name)
    else
      where 'path is not null'
    end
  }

end
