# encoding: utf-8

class AudioFileTemplate < BaseModel

  include IntegerEnhancements

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

  def validate_audio_file(file)
    audio_length_errors(file)
  end

  private

  def audio_length_errors(file)
    return "Audio file '#{file.label}' has no duration." unless file.length

    length_errors = ''
    shorter_than_min = file.length < length_minimum
    longer_than_max = length_maximum != 0 && file.length > length_maximum

    if shorter_than_min || longer_than_max
      length_errors << "Audio file '#{file.label}' is " +
                       "#{file.length.to_time_string} long, but " +
                       "must be #{length_minimum.to_time_string} " +
                       "- #{length_maximum.to_time_string} long."
    end
    length_errors
  end
end
