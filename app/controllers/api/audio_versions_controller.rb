# encoding: utf-8

class Api::AudioVersionsController < Api::BaseController
  api_versions :v1

  filter_resources_by :story_id

  announce_actions resource: :story_resource, action: :update

  def story_resource
    resource.try(:story)
  end
end
