# encoding: utf-8

require 'api/story_distribution_representer'
require 'api/story_distributions/episode_distribution_representer'

class Api::StoryDistributionsController < Api::BaseController
  api_versions :v1

  filter_resources_by :story_id

  announce_actions resource: :story_resource

  def story_resource
    resource.try(:story)
  end

  def create
    create_resource.tap do |res|
      consume! res, create_options
      res = res.becomes(res.type.safe_constantize) if res.type
      hal_authorize res
      res.save!
      distribute(res)
      respond_with root_resource(res), create_distribution_options(res)
    end
  end

  def create_distribution_options(distribution)
    create_options.tap do |options|
      dec = decorator_for_model(distribution)
      options[:represent_with] = dec if dec
    end
  end

  def distribute(distribution)
    distribution.distribute
  end
end
