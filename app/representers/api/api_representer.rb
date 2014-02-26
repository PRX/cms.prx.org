# encoding: utf-8

class Api::ApiRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL
  include Api::UrlRepresenterHelper

  property :version

  link :self do
    api_root_path(represented.version)
  end

  links :stories do
    [
      {
        profile:   prx_model_uri(:story),
        href:      api_stories_path_template(api_version: represented.version) + '{?page}',
        templated: true
      },
      {
        profile:   prx_model_uri(:story),
        href:      api_story_path_template(api_version: represented.version, id: '{id}'),
        templated: true
      }
    ]
  end

end
