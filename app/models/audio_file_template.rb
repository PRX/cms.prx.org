# encoding: utf-8

class AudioFileTemplate < BaseModel

  include IntegerEnhancements

  belongs_to :audio_version_template

  acts_as_list scope: :audio_version_template

  before_validation :set_defaults, on: :create

  validates :length_minimum,
            presence: true,
            numericality: true

  validates :length_maximum,
            presence: true,
            numericality: true

  validate :max_is_greater_than_min_if_set

  after_commit :touch_audio_version_template

  def touch_audio_version_template
    audio_version_template.try(:touch)
  end

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
    shorter_than_min = length_minimum != 0 && file.length < length_minimum
    longer_than_max = length_maximum != 0 && file.length > length_maximum
    if shorter_than_min || longer_than_max
      length_errors = "File '#{file.label}' is " +
                      "#{file.length.to_time_string} long but must be "
      length_errors << if length_maximum != 0
                         "#{length_minimum.to_time_string} - " +
                         "#{length_maximum.to_time_string} long"
                       else
                         "more than #{length_minimum.to_time_string} long"
                       end
      length_errors
    end
  end

  def max_is_greater_than_min_if_set
    if length_maximum != 0 && length_minimum > length_maximum
      errors.add(:length_mininum, 'must be less than or equal to length maximum')
    end
  end
end
