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
            numericality: { less_than_or_equal_to: :length_maximum }

  validates :length_maximum,
            presence: true,
            numericality: { greater_than_or_equal_to: :length_minimum }

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
     audio_length_errors(audio_version),
     label_mismatch_errors(audio_version)].join(' ').strip
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
      length_errors << "Duration of audio version #{audio_version.label} is " +
                       "#{audio_version.length.to_time_string}, but the '#{audio_version.label}' must be " +
                       "between #{length_minimum.to_time_string} and #{length_maximum.to_time_string}."
    end
    length_errors
  end

  def label_mismatch_errors(audio_version)
    label_errors = ''

    if audio_version.label.downcase.strip != label.downcase.strip
      label_errors << "Audio version #{audio_version.label} should be labeled #{label}."
    end

    req_pos_and_labels = {}
    audio_file_templates.each { |aft| req_pos_and_labels[aft.position] = aft.label }

    audio_version.audio_files.each do |af|
      template_label = req_pos_and_labels[af.position]
      no_label = template_label.nil? || af.label.nil?
      label_mismatch = template_label != af.label
      if !no_label && label_mismatch
        label_errors << "Audio file #{af.position} of audio version #{audio_version.label} " +
                        "should be #{template_label}, not #{af.label}. "
      end
    end
    label_errors
  end
end
