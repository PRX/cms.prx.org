# encoding: utf-8

class MusicalWork < BaseModel

  belongs_to :story, -> { with_deleted }, class_name: 'Story', foreign_key: 'piece_id', touch: true

  acts_as_list scope: :piece_id

  alias_attribute :duration, :excerpt_length

  def self.policy_class
    StoryAttributePolicy
  end
end
