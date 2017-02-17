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
    [audio_length_errors(file), label_mismatch_errors(file)].join(' ').strip
  end

  private

  def audio_length_errors(file)
    length_errors = ''
    shorter_than_min = file.length < length_minimum
    longer_than_max = length_maximum != 0 && file.length > length_maximum

    if shorter_than_min || longer_than_max
      length_errors << "Audio file #{file.position} '#{file.label}' is " +
                       "#{file.length.to_time_string}, but the '#{file.label}' " +
                       "must be between #{length_minimum.to_time_string} " +
                       "and #{length_maximum.to_time_string}."
    end
    length_errors
  end

  def label_mismatch_errors(file)
    if file.label.downcase.strip == label.downcase.strip
      ''
    else
      "Audio file at position #{position} should be labeled #{label}, not #{file.label}."
    end
  end
end
