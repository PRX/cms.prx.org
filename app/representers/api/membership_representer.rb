# encoding: utf-8

class Api::MembershipRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :role
  property :approved
  property :request

  link :self do
    api_membership_path(represented)
  end

  link :account do
    api_account_path(represented.account)
  end

  link :user do
    api_user_path(represented.user)
  end

end
