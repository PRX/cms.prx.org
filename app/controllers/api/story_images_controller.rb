# encoding: utf-8

class Api::StoryImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :story_id

  announce_actions decorator: Api::ImageRepresenter, subject: :image

  represent_with Api::ImageRepresenter
end
