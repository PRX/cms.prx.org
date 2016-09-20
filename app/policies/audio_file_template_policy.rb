class AudioFileTemplatePolicy < ApplicationPolicy
  def create?
    update?
  end

  def update?
    SeriesAttributePolicy.new(token, resource.audio_version_template).update?
  end
end
