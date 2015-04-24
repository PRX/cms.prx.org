# encoding: utf-8

class Api::AuthorizationRepresenter < Api::BaseRepresenter
  property :id

  link :accounts do
    {
      href: "#{api_authorization_accounts_path}{?page,per,zoom}",
      templated: true,
      count: represented.accounts.count
    }
  end
  embed :accounts, paged: true, item_class: Account, item_decorator: Api::Min::AccountRepresenter, per: :all
end
