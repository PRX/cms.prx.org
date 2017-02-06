# encoding: utf-8

class AudioVersionTemplate < BaseModel
  belongs_to :series, touch: true

  has_many :audio_file_templates, -> { order :position }, dependent: :destroy

  has_many :audio_versions, dependent: :nullify
  has_many :distributions, dependent: :nullify

  after_save :touch_audio_versions

  after_touch :touch_audio_versions

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

  def touch_audio_versions
    audio_versions.update_all(updated_at: Time.now)
  end

end
