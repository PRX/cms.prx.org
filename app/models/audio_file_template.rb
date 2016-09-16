# encoding: utf-8

class AudioFileTemplate < BaseModel
  belongs_to :audio_version_template
  acts_as_list scope: :audio_version_template

  validates :length_minimum,
    presence: true,
    numericality: { less_than_or_equal_to: :length_maximum }

  validates :length_maximum,
    presence: true,
    numericality: { greater_than_or_equal_to: :length_minimum }
end
