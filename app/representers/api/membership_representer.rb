# encoding: utf-8

class Api::MembershipRepresenter < Api::BaseRepresenter

  property :id
  property :role
  property :approved
  property :request

  link :account do
    api_account_path(represented.account)
  end

  link :user do
    api_user_path(represented.user)
  end

end
