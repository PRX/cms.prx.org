# encoding: utf-8

class AudioFileTemplate < BaseModel
  belongs_to :audio_version_template, touch: true

  acts_as_list scope: :audio_version_template

  before_validation :set_defaults, on: :create

  validates :length_minimum,
            presence: true,
            numericality: { less_than_or_equal_to: :length_maximum }

  validates :length_maximum,
            presence: true,
            numericality: { greater_than_or_equal_to: :length_minimum }

  def set_defaults
    self.label ||= 'segment'
    self.length_minimum ||= 0
    self.length_maximum ||= 0
  end
end
