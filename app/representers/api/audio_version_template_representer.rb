# encoding: utf-8

class Api::AudioVersionTemplateRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :label
  property :promos
  property :segment_count
  property :length_minimum
  property :length_maximum

  set_link_property(rel: :series, writeable: true)

  link :audio_file_templates do
    {
      href: api_audio_version_template_audio_file_templates_path(represented),
      count: represented.audio_file_templates.count
    } if represented.id
  end
  embeds :audio_file_templates, class: AudioFileTemplate, decorator: Api::AudioFileTemplateRepresenter
end
