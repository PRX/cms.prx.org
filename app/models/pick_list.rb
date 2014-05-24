# encoding: utf-8

class PickList < BaseModel
  acts_as_paranoid

  self.table_name = 'playlists'

  default_scope { where(type: nil) }  # no portfolios
  scope :named, ->(name=nil) {
    if name
      where(path: name)
    else
      where 'path is not null'
    end
  }

  has_many :playlist_sections, :foreign_key => 'playlist_id'
  has_many :picks, :through => :playlist_sections
  belongs_to :account

  def self.find_by_id_or_path(path_or_id)
    p = self.find_by_path(path_or_id)
    p = self.find_by_id(path_or_id) if !p
    p
  end

end
