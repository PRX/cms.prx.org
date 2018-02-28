# encoding: utf-8

class Api::AudioVersionTemplateRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :label
  property :content_type
  property :promos
  property :length_minimum
  property :length_maximum

  set_link_property(rel: :series, writeable: true)

  link :audio_file_templates do
    if represented.id
      {
        href: api_audio_version_template_audio_file_templates_path(represented),
        count: represented.audio_file_templates.count
      }
    end
  end
  embed :audio_file_templates,
        paged: true,
        item_class: AudioFileTemplate,
        item_decorator: Api::AudioFileTemplateRepresenter
end
