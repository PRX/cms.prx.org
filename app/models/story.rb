# encoding: utf-8

class Story < BaseModel
  APPLICATION_VERSION = 'v4'
  self.table_name = 'pieces'

  acts_as_paranoid

  def self.paranoia_scope
    where(
      arel_table[paranoia_column].eq(paranoia_sentinel_value).or(
        arel_table['app_version'].eq(APPLICATION_VERSION)
      )
    )
  end

  belongs_to :account, -> { with_deleted }
  belongs_to :creator, -> { with_deleted }, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :series, touch: true
  belongs_to :network

  has_many :images, -> { where(parent_id: nil).order(:position) }, class_name: 'StoryImage', foreign_key: :piece_id
  has_many :audio_versions, -> { where(promos: false).includes(:audio_files) }, foreign_key: :piece_id
  has_many :audio_files, through: :audio_versions
  has_many :producers
  has_many :musical_works, -> { order(:position) }, foreign_key: :piece_id
  has_many :topics, foreign_key: :piece_id
  has_many :tones, foreign_key: :piece_id
  has_many :formats, foreign_key: :piece_id
  has_many :taggings, as: :taggable
  has_many :user_tags, through: :taggings
  has_many :picks, foreign_key: 'playlistable_id'
  has_many :playlists, through: :picks
  has_many :purchases, foreign_key: :purchased_id

  has_one :promos, -> { where(promos: true) }, class_name: 'AudioVersion', foreign_key: :piece_id
  has_one :license, foreign_key: :piece_id

  before_validation :set_app_version, on: :create

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

  scope :published, -> { where('`published_at` IS NOT NULL') }

  scope :unpublished, -> { where('`published_at` IS NULL') }

  scope :unseries, -> { where('`series_id` IS NULL') }

  scope :purchased, -> {
    joins(:purchases).
    select('`pieces`.*', 'COUNT(`purchases`.`id`) AS `purchase_count`').group('`pieces`.`id`')
  }

  scope :network_visible, -> { where('`network_only_at` IS NULL') }

  scope :series_visible, -> {
    joins('LEFT OUTER JOIN `series` ON `pieces`.`series_id` = `series`.`id`').
    where(['`series`.`subscription_approval_status` != ? OR `series`.`subscriber_only_at` IS NULL',
           Series::SUBSCRIPTION_PRX_APPROVED])
  }

  def points(level=point_level)
    has_custom_points? ? self.custom_points : Economy.points(level, self.length)
  end

  def default_image
    @default_image ||= images.first || series.try(:image)
  end

  def default_audio_version
    @default_audio_version ||= longest_single_file_version || longest_version
  end

  def promos_audio
    @promos_audio ||= promos.try(:audio_files) || Kaminari.paginate_array([])
  end

  def default_audio
    @default_audio ||= default_audio_version.try(:audio_files) || Kaminari.paginate_array([])
  end

  def duration
    default_audio_version.try(:duration) || 0
  end

  def timing_and_cues
    default_audio_version.try(:timing_and_cues)
  end

  def timing_and_cues=(taq)
    default_audio_version.try(:timing_and_cues=, taq)
  end

  def content_advisory
    default_audio_version.try(:content_advisory)
  end

  def content_advisory=(ca)
    default_audio_version.try(:content_advisory=, ca)
  end

  def tags
    (topics + tones + formats + user_tags).map(&:to_tag).uniq.sort
  end

  def tags=(ts)
    self.user_tags = ts.uniq.sort.map { |t| UserTag.new(name: t) }
  end

  def self.policy_class
    StoryPolicy
  end

  def episode_date
    @episode_date || if subscription_episode? && episode_number
      series.get_datetime_for_episode_number(episode_number)
    end
  end

  def subscription_episode?
    series && series.subscribable?
  end

  # raising exceptions here to prevent sending publish messages
  #  when not actually a change to be published
  def publish!
    if published?
      raise "Story #{id} is already published."
    else
      update_attributes!(published_at: Time.now)
    end
  end

  def unpublish!
    if !published?
      raise "Story #{id} is not published."
    else
      update_attributes!(published_at: nil)
    end
  end

  def destroy
    if v4?
      really_destroy!
    else
      super
    end
  end

  private

  def longest_single_file_version
    audio_versions.reject { |av| av.audio_files.size != 1 }.sort_by(&:length).last
  end

  def longest_version
    audio_versions.sort_by(&:length).last
  end

  def set_app_version
    return unless new_record?
    self.app_version = APPLICATION_VERSION
    self.deleted_at = Time.now
  end

  def v4?
    app_version == APPLICATION_VERSION
  end
end
