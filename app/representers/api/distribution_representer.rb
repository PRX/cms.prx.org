# encoding: utf-8

class Api::DistributionRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :guid
  property :url
  property :kind
  hash :properties

  def self_url(represented)
    polymorphic_path([:api, represented.owner, represented.becomes(Distribution)])
  end

  link :owner do
    {
      href: polymorphic_path([:api, represented.owner]),
      profile: model_uri(represented.owner)
    } if represented.id && represented.owner
  end

  link rel: :audio_version_template, writeable: true do
    {
      href: api_audio_version_template_path(represented.audio_version_template)
    } if represented.audio_version_template_id
  end
  embed :audio_version_template,
        class: AudioVersionTemplate,
        decorator: Api::AudioVersionTemplateRepresenter

  link :audio_version_templates do
    {
      href: api_distribution_audio_version_templates_path(represented),
      count: represented.audio_version_templates.count
    } if represented.id
  end
  embed :audio_version_templates,
        paged: true,
        item_class: AudioVersionTemplate,
        item_decorator: Api::AudioVersionTemplateRepresenter
end
