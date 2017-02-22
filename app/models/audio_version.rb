# encoding: utf-8

class AudioVersion < BaseModel

  include ValidityFlag

  belongs_to :story, -> { with_deleted },
             class_name: 'Story',
             foreign_key: 'piece_id', touch: true

  belongs_to :audio_version_template
  has_many :audio_files, -> { order :position }, dependent: :destroy

  before_save :validate_on_template

  acts_as_paranoid

  def length(reload=false)
    @_length = nil if reload
    @_length ||= audio_files.inject(0) { |sum, f| sum + f.length.to_i }
  end

  alias_method :duration, :length

  def self.policy_class
    StoryAttributePolicy
  end

  def compliant_with_template?
    file_errors.nil?
  end

  private

  def validate_on_template
    return unless audio_version_template

    noncompliant_file_errors = audio_files.select do |af|
      !af.compliant_with_template? || af.status == INVALID
    end.try(:map) { |af| af.file_errors }.join(',')
    if !noncompliant_file_errors.empty?
      self.status = INVALID
      self.file_errors = noncompliant_file_errors
      return
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
