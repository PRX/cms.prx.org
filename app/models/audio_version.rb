# encoding: utf-8

class AudioVersion < BaseModel

  VALID            = 'valid'.freeze
  INVALID          = 'invalid'.freeze

  belongs_to :story, -> { with_deleted },
             class_name: 'Story',
             foreign_key: 'piece_id', touch: true

  belongs_to :audio_version_template
  has_many :audio_files, -> { order :position }, dependent: :destroy

  after_touch :validate_on_template

  acts_as_paranoid

  def length(reload=false)
    @_length = nil if reload
    @_length ||= audio_files.inject(0) { |sum, f| sum + f.length.to_i }
  end

  alias_method :duration, :length

  def self.policy_class
    StoryAttributePolicy
  end

  def validate_on_template
    return unless audio_version_template

    audio_files.each do |af|
      af.validate_on_template
      if !af.compliant_with_template?
        self.status = INVALID
        self.file_errors = af.audio_errors
        return
      end
    end

    errors = audio_version_template.validate_audio_version(self)
    if errors.empty?
      self.status = VALID
      self.file_errors = nil
    else
      self.status = INVALID
      self.file_errors = errors
    end
  end
end
