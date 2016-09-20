# encoding: utf-8

class Api::AudioVersionRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :label
  property :timing_and_cues
  property :explicit
  property :transcript

  set_link_property(rel: :story, writeable: true)

  link :audio do
    {
      href: api_audio_version_audio_files_path(represented),
      count: represented.audio_files.count
    } if represented.id
  end
  embeds :audio_files, as: :audio, class: AudioFile, decorator: Api::AudioFileRepresenter

  link :audio_version_template do
    {
      href: api_audio_version_template_path(represented.audio_version_template)
    } if represented.audio_version_template_id
  end
  embed :audio_version_template,
        class: AudioVersionTemplate,
        decorator: Api::AudioVersionTemplateRepresenter
end
