# encoding: utf-8

class AudioVersionTemplate < BaseModel
  belongs_to :series

  has_many :audio_file_templates, -> { order :position }, dependent: :destroy

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
end
