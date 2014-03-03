# encoding: utf-8

class Api::ApiRepresenter < Api::BaseRepresenter

  property :version

  link(:self) { api_root_path(represented.version) }

  links :story do
    [
      {
        profile:   prx_model_uri(:story),
        href:      api_story_path_template(api_version: represented.version, id: '{id}'),
        templated: true
      }
    ]
  end

  links :stories do
    [
      {
        profile:   prx_model_uri(:collection, :story),
        href:      api_stories_path_template(api_version: represented.version) + '{?page}',
        templated: true
      }
    ]
  end

  links :series do
    [
      {
        profile:   prx_model_uri(:series),
        href:      api_series_path_template(api_version: represented.version, id: '{id}'),
        templated: true
      },
      {
        profile:   prx_model_uri(:collection, :series),
        href:      api_series_index_path_template(api_version: represented.version) + '{?page}',
        templated: true
      }
    ]
  end

end
