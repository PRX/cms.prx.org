# encoding: utf-8

class Api::AudioFileTemplateRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :position
  property :label
  property :length_minimum
  property :length_maximum

  def self_url(represented)
    polymorphic_path([:api, represented.audio_version_template, represented])
  end

  set_link_property(rel: :audio_version_template, writeable: true)
end
