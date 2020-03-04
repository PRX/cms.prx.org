# encoding: utf-8

class Api::StoryImagesController < Api::BaseImagesController
  api_versions :v1
  represent_with Api::ImageRepresenter

  filter_resources_by :story_id
end
