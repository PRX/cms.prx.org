# encoding: utf-8

class Story < BaseModel

  acts_as_paranoid

  self.table_name = 'pieces'

  belongs_to :account, with_deleted: true
  belongs_to :creator, class_name: 'User',foreign_key: 'creator_id', with_deleted: true
  belongs_to :series

  has_many :images, -> { where(parent_id: nil).order(:position) }, class_name: 'StoryImage', foreign_key: :piece_id
  has_many :audio_versions, -> { where(promos: false).includes(:audio_files) }, foreign_key: :piece_id
  has_many :audio_files, through: :audio_versions
  has_many :producers
  has_many :musical_works, -> { order(:position) }, foreign_key: :piece_id
  has_many :topics, foreign_key: :piece_id
  has_many :tones, foreign_key: :piece_id

  has_one :promos, -> { where(promos: true) }, class_name: 'AudioVersion', foreign_key: :piece_id
  has_one :license, foreign_key: :piece_id

  # indicates piece is published
  event_attribute :published_at

  # indicates piece is published with promos only - not full audio
  event_attribute :promos_only_at

  # indicates that there is publish streaming and embedding of the piece, default (see observer)
  event_attribute :is_shareable_at

  # lets us override the number of points
  event_attribute :has_custom_points_at

  # indicates the piece is not publically available, only to the network
  event_attribute :network_only_at

  scope :published, -> { where('published_at is not null and network_only_at is null') }

  def points(level=point_level)
    has_custom_points? ? self.custom_points : Economy.points(level, self.length)
  end

  def default_image
    @default_image ||= images.first || series.try(:image)
  end

  def default_audio_version
    @default_audio_version ||= if promos_only?
      promos
    else
      audio_versions.reject{|av| av.audio_files.size < 1 }.sort{|a, b| compare_versions(a,b) }.first
    end
  end

  def default_audio
    @default_audio ||= default_audio_version.try(:as_default_audio) || []
  end

  def duration
    default_audio_version.try(:default_audio_duration) || 0
  end

  def compare_versions(a,b)
    if a.audio_files.size == b.audio_files.size
      b.length <=> a.length
    else
      a.audio_files.size <=> b.audio_files.size
    end
  end

  def timing_and_cues
    default_audio_version.try(:timing_and_cues)
  end

  def content_advisory
    default_audio_version.try(:content_advisory)
  end

  def tags
    topics + tones
  end

end
