# encoding: utf-8

class Story < PRXModel

  self.table_name = 'pieces'

  belongs_to :account, with_deleted: true
  belongs_to :creator, class_name: 'User',foreign_key: 'creator_id', with_deleted: true
  belongs_to :series

  has_many :images, -> { where(parent_id: nil).order(:position) }, class_name: 'StoryImage', foreign_key: :piece_id
  has_many :audio_versions, -> { where(promos: false).includes(:audio_files) }, foreign_key: :piece_id
  has_many :audio_files, through: :audio_versions
  has_many :producers

  has_one :promos, -> { where(promos: true) }, class_name: 'AudioVersion', foreign_key: :piece_id
  has_one :license, foreign_key: :piece_id

  acts_as_paranoid

  # indicates piece is published
  event_attribute :published_at

  # indicates piece is published with promos only - not full audio
  event_attribute :promos_only_at

  # indicates that there is publish streaming and embedding of the piece, default (see observer)
  event_attribute :is_shareable_at

  # lets us override the number of points
  event_attribute :has_custom_points_at

  scope :published, -> { where('published_at is not null') }

  def points(level=point_level)
    has_custom_points? ? self.custom_points : Economy.points(level, self.length)
  end

  def default_image
    images.first
  end

  def default_audio_version
    @_default_audio_version ||= if promos_only?
      promos
    else
      audio_versions.reject{|av| av.audio_files.size < 1 }.sort{|a, b| compare_versions(a,b) }.first
    end
  end

  def default_audio
    return [] unless default_audio_version
    return [default_audio_version.audio_files.max_by{|af| af.length }] if default_audio_version.promos?
    default_audio_version.audio_files
  end

  def compare_versions(a,b)
    if a.audio_files.size == b.audio_files.size
      b.length <=> a.length
    else
      a.audio_files.size <=> b.audio_files.size
    end
  end

end
