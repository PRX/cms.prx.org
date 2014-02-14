class Api::AudioVersionRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :label

  link :self do
    api_audio_version_path(represented)
  end
end
