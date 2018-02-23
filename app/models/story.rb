# encoding: utf-8
require 'render_markdown'
require 'newrelic_rpm'

class Story < BaseModel
  self.table_name = 'pieces'

  include RenderMarkdown
  include ValidityFlag

  def description_html=(html)
    self.description = v4? ? html_to_markdown(html) : html
  end

  def description_html
    v4? ? markdown_to_html(description) : description
  end

  def description_md=(md)
    self.description = md
  end

  def description_md
    v4? ? description : html_to_markdown(description)
  end

  acts_as_paranoid

  def self.paranoia_scope
    where(
      arel_table[paranoia_column].eq(paranoia_sentinel_value).or(
        arel_table['app_version'].eq(PRX::APP_VERSION)
      )
    )
  end

  belongs_to :account, -> { with_deleted }
  belongs_to :creator, -> { with_deleted }, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :series, touch: true
  belongs_to :network

  has_many :images,
           -> { where(parent_id: nil).order(:position) },
           class_name: 'StoryImage',
           foreign_key: :piece_id,
           dependent: :destroy
  has_many :audio_versions, -> { where(promos: false).includes(:audio_files) }, foreign_key: :piece_id
  has_many :audio_files, through: :audio_versions
  has_many :producers, foreign_key: :piece_id, dependent: :destroy
  has_many :musical_works,
           -> { order(:position) },
           foreign_key: :piece_id,
           dependent: :destroy
  has_many :topics, foreign_key: :piece_id, dependent: :destroy
  has_many :tones, foreign_key: :piece_id, dependent: :destroy
  has_many :formats, foreign_key: :piece_id, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :user_tags, through: :taggings
  has_many :picks, foreign_key: 'playlistable_id', dependent: :destroy
  has_many :playlists, through: :picks
  has_many :purchases, foreign_key: :purchased_id
  has_many :distributions,
           class_name: 'StoryDistribution',
           foreign_key: :piece_id,
           dependent: :destroy

  has_one :promos,
          -> { where(promos: true).includes(:audio_files) },
          class_name: 'AudioVersion',
          foreign_key: :piece_id
  has_one :license, foreign_key: :piece_id, dependent: :destroy

  before_validation :set_app_version, on: :create
  before_validation :update_published_to_released

  before_save :set_status, only: [:update, :create]

  # indicates piece is published with promos only - not full audio
  event_attribute :promos_only_at

  # indicates that there is publish streaming and embedding of the piece, default (see observer)
  event_attribute :is_shareable_at

  # lets us override the number of points
  event_attribute :has_custom_points_at

  # indicates the piece is not publically available, only to the network
  event_attribute :network_only_at

  scope :published, -> { where('`published_at` <= ?', Time.now) }
  scope :unpublished, -> { where('`published_at` IS NULL OR `published_at` > ?', Time.now) }
  scope :unseries, -> { where('`series_id` IS NULL') }
  scope :v4, -> { where(app_version: PRX::APP_VERSION) }
  scope :network_visible, -> { where('`network_only_at` IS NULL') }
  scope :coalesce_published_released, -> {
    order('ISNULL(COALESCE(published_at, released_at)) DESC').
    order('COALESCE(published_at, released_at) DESC')
  }

  scope :series_visible, -> {
    joins('LEFT OUTER JOIN `series` ON `pieces`.`series_id` = `series`.`id`').
    where(['`series`.`subscription_approval_status` != ? OR `series`.`subscriber_only_at` IS NULL',
           Series::SUBSCRIPTION_PRX_APPROVED])
  }

  scope :purchased, -> {
    joins(:purchases).
    select('`pieces`.*', 'COUNT(`purchases`.`id`) AS `purchase_count`').group('`pieces`.`id`')
  }

  scope :match_text, ->(text) {
    where("`pieces`.`title` like '%#{text}%' OR " +
          "`pieces`.`short_description` like '%#{text}%' OR " +
          "`pieces`.`description` like '%#{text}%'")
  }

  scope :public_stories, -> { published.network_visible.series_visible }

  def points(level=point_level)
    has_custom_points? ? self.custom_points : Economy.points(level, self.length)
  end

  def default_image
    @default_image ||= images.first
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
    self.user_tags = (ts || []).uniq.sort.map { |t| UserTag.new(name: t) }
  end

  def transcript
    default_audio_version.try(:transcript)
  end

  def transcript=(tr)
    default_audio_version.try(:transcript=, tr)
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

  def published
    published_at && published_at <= DateTime.now
  end

  alias_method :"published?", :published

  def published=(value)
    self.published_at = date_for_boolean(value)
  end

  def date_for_boolean(value)
    if value.is_a?(Date) || value.is_a?(Time)
      value
    elsif [true, '1', 1, 't', 'true'].include? value
      DateTime.now
    elsif [false, '0', 0, 'f', 'false'].include? value
      nil
    else
      !!value ? DateTime.now : nil
    end
  end

  # raising exceptions here to prevent sending publish messages
  # when not actually a change to be published
  def publish!
    if !published_at.nil?
      raise "Story #{id} is already published."
    else
      update_attributes!(published_at: (released_at || DateTime.now))
    end
  end

  def unpublish!
    if published_at.nil?
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

  def v4?
    app_version == PRX::APP_VERSION
  end

  # for each distribution, create a story distribution
  def create_story_distributions
    return unless series
    series.distributions.each { |distro| create_single_story_distribution(distro) }
  end

  def create_single_story_distribution(distro)
    return unless distro
    begin
      distro.create_story_distribution(self)
    rescue StandardError => err
      logger.error(err)
      NewRelic::Agent.notice_error(err)
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
    self.app_version = PRX::APP_VERSION
    self.deleted_at = DateTime.now
  end

  # If story is published and user wants to update the published_at value
  # OR if story is published for future release and user wants to undo that
  def update_published_to_released
    canceling_future_release = released_at.nil? && published_at && published_at > DateTime.now
    updating_release = !released_at.nil?
    if published_at && released_at_changed? && (canceling_future_release || updating_release)
        self.published_at = released_at
    end
  end

  def set_status
    av_errors = ''
    if audio_versions.empty?
      av_errors << "Story '#{title}' has no audio."
    else
      audio_versions.each do |av|
        if !av.compliant_with_template? || av.status == INVALID
          av_errors << "Invalid audio version: '#{av.label}.' "
        end
      end
    end

    if av_errors.empty?
      self.status = COMPLETE
      self.status_message = nil
    else
      self.status = INVALID
      self.status_message = av_errors.strip
    end
  end
end
