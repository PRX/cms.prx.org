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

  def self_url(_r)
    api_authorization_path
  end

end
