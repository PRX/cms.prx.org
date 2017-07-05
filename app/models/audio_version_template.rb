# encoding: utf-8

class AudioVersionTemplate < BaseModel

  include IntegerEnhancements

  belongs_to :series, touch: true

  has_many :audio_file_templates, -> { order :position }, dependent: :destroy

  has_many :audio_versions, dependent: :nullify
  has_many :distributions, dependent: :nullify

  after_save :touch_audio_versions

  after_touch :touch_audio_versions

  before_validation :set_defaults, on: :create

  validates :label, presence: true

  validates :length_minimum,
            presence: true,
            numericality: true

  validates :length_maximum,
            presence: true,
            numericality: true

  validate :max_is_greater_than_min_if_set

  def self.policy_class
    SeriesAttributePolicy
  end

  def set_defaults
    self.length_minimum ||= 0
    self.length_maximum ||= 0
  end

  def touch_audio_versions
    audio_versions.update_all(updated_at: Time.now)
  end

  def validate_audio_version(audio_version)
    [audio_file_count_errors(audio_version),
     audio_length_errors(audio_version)].join(' ').strip
  end

  private

  def audio_file_count_errors(audio_version)
    file_count_errors = ''
    num_audio_files = audio_version.audio_files.count
    if !segment_count.nil? && audio_version.audio_files.count != segment_count
      file_count_errors << "Audio version #{audio_version.label} has #{num_audio_files} " +
                           "audio files, but must have #{segment_count} segments."
    end
    file_count_errors
  end

  def audio_length_errors(audio_version)
    length_errors = ''
    shorter_than_min = audio_version.length < length_minimum
    longer_than_max = length_maximum != 0 && audio_version.length > length_maximum
    if shorter_than_min || longer_than_max
      length_errors << "Audio version '#{audio_version.label}' is " +
                       "#{audio_version.length.to_time_string} long, but " +
                       "must be #{length_minimum.to_time_string} " +
                       "- #{length_maximum.to_time_string} long."
    end
    length_errors
  end

  def max_is_greater_than_min_if_set
    if length_maximum != 0 && length_minimum > length_maximum
      errors.add(:length_mininum, 'must be less than or equal to length maximum')
    end
  end
end
