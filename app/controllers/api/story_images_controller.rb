# encoding: utf-8

class Api::StoryImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :story_id

  represent_with Api::ImageRepresenter

end
