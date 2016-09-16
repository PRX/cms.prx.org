# encoding: utf-8

class AudioVersionTemplate < BaseModel
  belongs_to :series
  has_many :audio_file_templates, -> { order :position }, dependent: :destroy

  after_save :sync_audio_file_templates

  validates :label, presence: true

  validates :length_minimum,
            presence: true,
            numericality: { less_than_or_equal_to: :length_maximum }

  validates :length_maximum,
            presence: true,
            numericality: { greater_than_or_equal_to: :length_minimum }

  validates :segment_count,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  def sync_audio_file_templates
    diff = segment_count - audio_file_templates.count
    if diff > 0
      diff.times { audio_file_templates.create! }
    elsif diff < 0
      self.audio_file_templates = audio_file_templates[0, segment_count]
    end
  end
end
