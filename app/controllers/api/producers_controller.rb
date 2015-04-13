# encoding: utf-8

class Api::ProducersController < Api::BaseController

  api_versions :v1

  filter_resources_by :story_id, :user_id
end
