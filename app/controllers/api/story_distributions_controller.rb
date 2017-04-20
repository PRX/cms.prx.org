# encoding: utf-8

require 'abstract_resource'
require 'api/story_distribution_representer'
require 'api/story_distributions/episode_distribution_representer'

class Api::StoryDistributionsController < Api::BaseController
  include AbstractResource

  api_versions :v1

  filter_resources_by :story_id

  announce_actions resource: :story_resource, action: :update

  around_action :wrap_in_transaction, only: :create

  def story_resource
    resource.try(:story)
  end

  def after_create_resource(res)
    res.distribute! if res
  end
end
