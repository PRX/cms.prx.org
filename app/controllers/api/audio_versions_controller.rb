# encoding: utf-8

class Api::AudioVersionsController < Api::BaseController

  api_versions :v1

  filter_resources_by :story_id

end
