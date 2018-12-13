# encoding: utf-8

require 'abstract_resource'

class Api::AccountsController < Api::BaseController
  include AbstractResource

  api_versions :v1

  represent_with Api::AccountRepresenter

  # filter_resources_by :user_id

  # Unless there's already an opener, set it to the authenticated user
  def create_resource
    super.tap do |acct|
      acct.opener_id ||= current_user.id
      acct
    end
  end

  private

  def resources
    @resources ||= super.member
  end

  def resources_base
    user.try(:accounts) || super
  end

  def user
    @user ||= User.find(params[:user_id]) if params[:user_id]
  end

  def scoped(relation)
    relation.active
  end

# TODO: refactor existing app to have membership record for user to be admin of individual account
# This would be the right thing to do if there was consistency in how accounts are associated to a user.
# Once that TODO above is done, this can be used instead of the `resources` method
  # filter_resources_by :user_id
end
