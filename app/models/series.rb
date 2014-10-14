# encoding: utf-8

class Series < BaseModel

  belongs_to :account, with_deleted: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', with_deleted: true

  has_many :stories, -> { where('published_at is not null and network_only_at is null').order('episode_number DESC, position DESC, published_at DESC') }

  has_one :image, -> { where(parent_id: nil) }, class_name: 'SeriesImage'

  acts_as_paranoid

  def story_count
    @story_count ||= self.stories.published.count
  end

  def self.policy_class
    AccountablePolicy
  end
end
