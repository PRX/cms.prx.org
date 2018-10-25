# encoding: utf-8

class Api::AuthorizationRepresenter < Api::BaseRepresenter
  property :id, writeable: false

  link :default_account do
    {
      href: api_authorization_account_path(represented.default_account)
    }
  end
  embed :default_account, decorator: Api::Auth::AccountMinRepresenter

  link :accounts do
    {
      href: "#{api_authorization_accounts_path}#{index_url_params}",
      templated: true,
      count: represented.token_auth_accounts.count
    }
  end
  embed :token_auth_accounts, as: :accounts, paged: true, per: :all, item_class: Account,
                                   item_decorator: Api::Auth::AccountMinRepresenter,
                                   url: ->(_r) { api_authorization_accounts_path }

  links :series do
    [
      {
        href: "#{api_authorization_series_path_template(id: '{id}')}#{show_url_params}",
        templated: true,
        count: represented.token_auth_series.count
      },
      {
        href: "#{api_authorization_series_index_path}#{index_url_params}",
        templated: true,
        count: represented.token_auth_series.count
      }
    ]
  end

  link :series_search do
    {
      href: "#{search_api_authorization_series_index_path}#{search_url_params}",
      templated: true,
      count: represented.token_auth_series.count
    }
  end

  link :stories do
    {
      href: "#{api_authorization_stories_path}#{index_url_params}",
      templated: true,
      count: represented.token_auth_stories.count
    }
  end

  link :stories_search do
    {
      href: "#{search_api_authorization_stories_path}#{search_url_params}",
      templated: true,
      count: represented.token_auth_stories.count
    }
  end

  link :story do
    {
      href: "#{api_authorization_story_path_template(id: '{id}')}#{show_url_params}",
      templated: true,
    }
  end

  link :network do
    {
      href: "#{api_authorization_network_path_template(id: '{id}')}#{show_url_params}",
      templated: true,
    }
  end

  link :podcast_imports do
    {
      href: "#{api_authorization_podcast_imports_path}#{index_url_params}",
      templated: true,
      count: represented.podcast_imports.count
    }
  end

  link :podcast_import do
    {
      href: "#{api_authorization_podcast_import_path_template(id: '{id}')}#{show_url_params}",
      templated: true
    }
  end

  link :verify_rss do
    {
      href: "#{verify_rss_api_authorization_podcast_imports_path}#{'{?url}'}",
      templated: true,
    }
  end

  def self_url(_r)
    api_authorization_path
  end
end
