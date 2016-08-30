# encoding: utf-8

class Api::AuthorizationRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :name

  link :default_account do
    {
      href: api_authorization_account_path(represented.default_account)
    }
  end
  embed :default_account, decorator: Api::Auth::AccountMinRepresenter

  link :accounts do
    {
      href: "#{api_authorization_accounts_path}{?page,per,zoom}",
      templated: true,
      count: represented.accounts.count
    }
  end
  embed :approved_active_accounts, as: :accounts, paged: true, per: :all, item_class: Account,
                                   item_decorator: Api::Auth::AccountMinRepresenter,
                                   url: ->(_r) { api_authorization_accounts_path }

  links :series do
    [
      {
        href: "#{api_authorization_series_path_template(id: '{id}')}{?zoom}",
        templated: true,
        count: represented.approved_account_series.count
      },
      {
        href: "#{api_authorization_series_index_path}{?page,per,zoom,filters}",
        templated: true,
        count: represented.approved_account_series.count
      }
    ]
  end

  link :stories do
    {
      href: "#{api_authorization_stories_path}{?page,per,zoom,filters}",
      templated: true,
      count: represented.approved_account_stories.count
    }
  end

  link :story do
    {
      href: "#{api_authorization_story_path_template(id: '{id}')}{?zoom}",
      templated: true,
    }
  end

  link :network do
    {
      href: "#{api_authorization_network_path_template(id: '{id}')}{?zoom}",
      templated: true,
    }
  end

  def self_url(_r)
    api_authorization_path
  end

end
