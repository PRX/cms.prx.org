# encoding: utf-8

class Series < BaseModel

  belongs_to :account, with_deleted: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', with_deleted: true

  has_many :stories, -> { order('episode_number DESC, position DESC') }

  has_one :image, -> { where(parent_id: nil) }, class_name: 'SeriesImage'

  acts_as_paranoid

  def story_count
    @story_count ||= self.stories.published.count
  end

end
