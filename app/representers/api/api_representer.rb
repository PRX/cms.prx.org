# encoding: utf-8

class Api::ApiRepresenter < Api::BaseRepresenter

  property :version

  link(:self) { api_root_path(represented.version) }

  links :story do
    [
      {
        title:     "Get a single story",
        profile:   prx_model_uri(:story),
        href:      api_story_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :stories do
    [
      {
        title:     "Get a paged collection of stories",
        profile:   prx_model_uri(:collection, :story),
        href:      api_stories_path_template(api_version: represented.version) + '{?page,per,zoom,filters}',
        templated: true
      }
    ]
  end

  links :series do
    [
      {
        title:     "Get a single series",
        profile:   prx_model_uri(:series),
        href:      api_series_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      },
      {
        title:     "Get a paged collection of series",
        profile:   prx_model_uri(:collection, :series),
        href:      api_series_index_path_template(api_version: represented.version) + '{?page,per,zoom}',
        templated: true
      }
    ]
  end

  links :account do
    [
      {
        title:     "Get a single account",
        profile:   prx_model_uri(:account),
        href:      api_account_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :accounts do
    [
      {
        title:     "Get a paged collection of accounts",
        profile:   prx_model_uri(:collection, :account),
        href:      api_accounts_path_template(api_version: represented.version) + '{?page,per,zoom}',
        templated: true
      }
    ]
  end

  links :picks do
    [
      {
        title:     "Get a paged collection of the most recent picks",
        profile:   prx_model_uri(:collection, :pick),
        href:      api_picks_path_template(api_version: represented.version) + '{?page,per,zoom}',
        templated: true
      }
    ]
  end

  link :authorization do
    {
      title: 'Get information about the active authorization for this request',
      profile: prx_model_uri(:authorization),
      href: api_authorization_path(api_version: represented.version),
      templated: false
    }
  end
end
