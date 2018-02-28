# encoding: utf-8

class Api::DistributionRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :guid
  property :url
  property :kind

  property :set_audio_version_template_uris,
           readable: false,
           reader: ->(doc, _args) do
             ids = doc['set_audio_version_template_uris']
             ids = Array(ids).map { |i| id_from_url i }
             set_template_ids(ids)
           end

  hash :properties

  def self_url(represented)
    polymorphic_path([:api, represented.owner, represented.becomes(Distribution)])
  end

  link :owner do
    if represented.id && represented.owner
      {
        href: polymorphic_path([:api, represented.owner]),
        profile: model_uri(represented.owner)
      }
    end
  end

  link rel: :audio_version_template, writeable: true do
    if represented.audio_version_template_id
      {
        href: api_audio_version_template_path(represented.audio_version_template)
      }
    end
  end
  embed :audio_version_template,
        class: AudioVersionTemplate,
        decorator: Api::AudioVersionTemplateRepresenter

  link :audio_version_templates do
    if represented.id
      {
        href: api_distribution_audio_version_templates_path(represented),
        count: represented.audio_version_templates.count
      }
    end
  end
  embed :audio_version_templates,
        paged: true,
        item_class: AudioVersionTemplate,
        item_decorator: Api::AudioVersionTemplateRepresenter
end
