# encoding: utf-8

class Series < BaseModel
  SUBSCRIPTION_STATES = [
    SUBSCRIPTION_NEW           = 'New',
    SUBSCRIPTION_STARTED       = 'Started',
    SUBSCRIPTION_USER_APPROVED = 'User Approved',
    SUBSCRIPTION_PRX_APPROVED  = 'PRX Approved'
  ]

  acts_as_paranoid

  belongs_to :account, -> { with_deleted }
  belongs_to :creator, -> { with_deleted }, class_name: 'User', foreign_key: 'creator_id'

  has_many :stories, -> { where('published_at is not null and network_only_at is null').order('episode_number DESC, position DESC, published_at DESC') }
  has_many :all_stories, foreign_key: 'series_id', class_name: 'Story'
  has_many :schedules

  has_one :image, -> { where(parent_id: nil) }, class_name: 'SeriesImage'

  event_attribute :subscriber_only_at

  def story_count
    @story_count ||= self.stories.published.count
  end

  def self.policy_class
    AccountablePolicy
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
end
