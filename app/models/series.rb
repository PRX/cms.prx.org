# encoding: utf-8
require 'render_markdown'

class Series < BaseModel
  SUBSCRIPTION_STATES = [
    SUBSCRIPTION_NEW           = 'New',
    SUBSCRIPTION_STARTED       = 'Started',
    SUBSCRIPTION_USER_APPROVED = 'User Approved',
    SUBSCRIPTION_PRX_APPROVED  = 'PRX Approved'
  ]

  include Storied
  include RenderMarkdown

  include Searchable

  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    mappings dynamic: 'true' do
      indexes :subscription_approval_status, type: 'keyword'
      indexes :use_porter, type: 'boolean'
    end
  end

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

  has_many :stories, -> { order('episode_number DESC, position DESC, published_at DESC') }, dependent: :nullify
  has_many :audio_files, through: :stories
  has_many :schedules
  has_many :audio_version_templates
  has_many :distributions, as: :distributable, dependent: :destroy

  has_many :images, -> { where(parent_id: nil) }, class_name: 'SeriesImage', dependent: :destroy

  has_many :podcast_imports

  before_validation :set_app_version, on: :create
  after_save :update_account_for_relations, on: :update

  event_attribute :subscriber_only_at

  scope :v4, -> { where('`app_version` = ?', PRX::APP_VERSION) }

  scope :match_text, ->(text) {
    where("`series`.`title` like '%#{text}%' OR " +
          "`series`.`short_description` like '%#{text}%' OR " +
          "`series`.`description` like '%#{text}%'")
  }

  attr_reader :import_url

  def self.create_from_feed(rss_url, user, account)
    pi = PodcastImport.create!(url: rss_url, user: user, account: account)
    pi.import_series!

    pi.import_later(import_series = false)

    pi.series
  end

  def self.text_search(text, params = {}, authz = nil)
    builder = SeriesQueryBuilder.new(query: text, params: params, authorization: authz)
    search(builder.as_dsl).records
  end

  def default_image
    @default_image ||= images.profile
  end

  def subscribable?
    subscription_approval_status == SUBSCRIPTION_PRX_APPROVED
  end

  def subscriber_only?
    subscribable? && subscriber_only_at.present?
  end

  def get_datetime_for_episode_number(episode_number)
    raise 'cannot calculate date for that episode number' if !episode_start_at || (episode_number < episode_start_number)
    # determine the number of episodes in a week
    episodes_per_week = schedules.length

    # get the schedule for the start, round time to the min + sec for the scheduled hour
    start_time, start_schedule = start_info

    # figure out what schedule is that episode ahead
    current_schedule = schedule_for_episode_number(episode_number)

    # get the full weeks between
    weeks_between = ((episode_number - episode_start_number) / episodes_per_week).to_i

    # get the days between
    days_between = schedules[current_schedule].day - schedules[start_schedule].day
    days_between = days_between + 7 if days_between < 0
    days_between = 7 if days_between == 0 && (schedules[start_schedule].hour > schedules[current_schedule].hour)

    #  add up the start, prior weeks, and the part of the final week
    # result = start_time + hours_between.hours + weeks_between.weeks
    result = start_time + weeks_between.weeks + days_between.days
    result = result.change(hour: schedules[current_schedule].hour)
    result
  end

  def start_info
    start_time = episode_start_at.in_time_zone(time_zone)
    # start_time = start_time.change(:hour=>0, :min=>0, :sec=>0)
    # start_schedule = schedule_for_datetime(start_time)

    start_schedule = 0
    value = start_time.hour + (start_time.wday * 24)
    schedules.each_with_index do |s, i|
      if (((s.day * 24) + s.hour) >= value)
          start_schedule = i
          break
      end
    end

    # this might be ahead or behind start
    day_diff = schedules[start_schedule].day - start_time.wday
    day_diff = day_diff + 7 if day_diff < 0

    start_time = start_time.change(hour: schedules[start_schedule].hour.to_i)
    start_time = start_time + day_diff.days

    [start_time, start_schedule]
  end

  def schedule_for_episode_number(episode_number)
    episodes_per_week = schedules.length
    return 0 if episodes_per_week == 1

    # get the schedule for the start
    start_time, start_schedule = start_info

    # full weeks between, and how many episodes that means
    weeks_between = ((episode_number - episode_start_number) / episodes_per_week).to_i
    episode_diff = episode_number - (episode_start_number + (episodes_per_week * weeks_between))

    # figure out what schedule is that episode ahead
    schedule_index = episode_diff + start_schedule
    schedule_index = schedule_index - episodes_per_week if schedule_index >= episodes_per_week

    schedule_index
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

  def self.policy_class
    SeriesPolicy
  end

  def import_url=(url)
    @import_url = url
  end

  def story_tags
    sql = %{
      SELECT distinct name FROM tags t
      JOIN taggings g ON (t.id = g.tag_id)
      JOIN pieces p ON (g.taggable_id = p.id)
      WHERE taggable_type = 'Story'
      AND p.series_id = #{id}
      ORDER BY t.name ASC
    }
    Series.connection.execute(sql).to_a.flatten
  end

  private

  def set_app_version
    return unless new_record?
    self.app_version = PRX::APP_VERSION
    self.deleted_at = DateTime.now
  end

  def update_account_for_relations
    if account_id_changed?
      Series.transaction do
        stories.update_all(account_id: account_id)
        audio_files.with_deleted.unscope(where: :promos).
          reorder('').update_all(account_id: account_id)
        podcast_imports.update_all(account_id: account_id)
      end
      stories.all.each(&:index_for_search)
    end
  end
end
