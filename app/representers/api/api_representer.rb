# encoding: utf-8

class Api::ApiRepresenter < Api::BaseRepresenter

  property :version

  def self_url(represented)
    api_root_path(represented.version)
  end

  links :story do
    [
      {
        title: 'Get a single story',
        profile: profile_url(:story),
        href: api_story_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :stories do
    [
      {
        title: 'Get a paged collection of stories',
        profile: profile_url(:collection, :story),
        href: api_stories_path_template(api_version: represented.version) + index_url_params,
        templated: true
      }
    ]
  end

  links :series do
    [
      {
        title: 'Get a single series',
        profile: profile_url(:series),
        href: api_series_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      },
      {
        title: 'Get a paged collection of series',
        profile: profile_url(:collection, :series),
        href: api_series_index_path_template(api_version: represented.version) + index_url_params,
        templated: true
      }
    ]
  end

  links :account do
    [
      {
        title: 'Get a single account',
        profile: profile_url(:account),
        href: api_account_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :accounts do
    [
      {
        title: 'Get a paged collection of accounts',
        profile: profile_url(:collection, :account),
        href: api_accounts_path_template(api_version: represented.version) + index_url_params,
        templated: true
      }
    ]
  end

  links :picks do
    [
      {
        title: 'Get a paged collection of the most recent picks',
        profile: profile_url(:collection, :pick),
        href: api_picks_path_template(api_version: represented.version) + index_url_params,
        templated: true
      }
    ]
  end

  link :authorization do
    {
      title: 'Get information about the active authorization for this request',
      profile: profile_url(:user),
      href: api_authorization_path(api_version: represented.version),
      templated: false
    }
  end

  links :network do
    [
      {
        title: 'Get a single network',
        profile: profile_url(:network),
        href: api_network_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :networks do
    [
      {
        title: 'Get a paged collection of networks',
        profile: profile_url(:collection, :network),
        href: api_networks_path_template(api_version: represented.version) + index_url_params,
        templated: true
      }
    ]
  end
end
