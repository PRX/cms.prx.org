# encoding: utf-8

class AudioVersionTemplate < BaseModel

  include IntegerEnhancements

  belongs_to :series, touch: true

  has_many :audio_versions, dependent: :nullify
  has_many :audio_file_templates, -> { order :position }, dependent: :destroy
  has_many :distribution_templates, dependent: :destroy
  has_many :distributions, through: :distribution_templates

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
    audio_file_count_errors(audio_version) || audio_length_errors(audio_version)
  end

  def validate_audio_file(audio_file)
    audio_file_content_type_errors(audio_file)
  end

  private

  def audio_file_count_errors(audio_version)
    num_audio_files = audio_version.audio_files.count
    if !segment_count.nil? && audio_version.audio_files.count != segment_count
      "Audio version #{audio_version.label} has #{num_audio_files} audio " +
        "files but must have #{segment_count} segments."
    end
  end

  def audio_length_errors(audio_version)
    shorter_than_min = length_minimum != 0 && audio_version.length < length_minimum
    longer_than_max = length_maximum != 0 && audio_version.length > length_maximum
    if shorter_than_min || longer_than_max
      length_errors = "Audio version '#{audio_version.label}' is " +
                      "#{audio_version.length.to_time_string} long but must be "
      length_errors << if length_maximum != 0
                         "#{length_minimum.to_time_string} - " +
                         "#{length_maximum.to_time_string} long."
                       else
                         "more than #{length_minimum.to_time_string} long."
                       end
      length_errors
    end
  end

  def max_is_greater_than_min_if_set
    if length_maximum != 0 && length_minimum > length_maximum
      errors.add(:length_mininum, 'must be less than or equal to length maximum')
    end
  end

  def audio_file_content_type_errors(audio_file)
    if content_type.present?
      tpl_type = content_type.split('/').first
      file_type = audio_file.content_type.try(:split, '/').try(:first)
      if content_type == 'audio/mpeg' && (audio_file.content_type != 'audio/mpeg' || audio_file.layer != 3)
        "Audio file '#{audio_file.label}' is not an mp3" # very specific on these
      elsif tpl_type != file_type
        "Audio file '#{audio_file.label}' is not #{articleize(tpl_type)}"
      end
    end
  end

  def articleize(word)
      %w(a e i o u).include?(word[0].downcase) ? "an #{word}" : "a #{word}"
  end
end
