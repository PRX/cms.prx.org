# encoding: utf-8

class Api::AudioVersionRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :label
  property :timing_and_cues

  link :self do
    api_audio_version_path(represented)
  end
end
