# encoding: utf-8

class Api::AudioFileTemplateRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :position
  property :label
  property :length_minimum
  property :length_maximum

  def self_url(represented)
    api_audio_version_template_audio_file_template_path(
      represented.audio_version_template,
      represented
    )
  end

  set_link_property(rel: :audio_version_template, writeable: true)
end
