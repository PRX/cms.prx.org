# encoding: utf-8

class AudioVersionTemplate < BaseModel
  belongs_to :series
  has_many :audio_file_templates
end
