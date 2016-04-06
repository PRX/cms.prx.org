# encoding: utf-8

class Api::Auth::StoriesController < Api::StoriesController

  include ApiAuthenticated

  api_versions :v1

  represent_with Api::Auth::StoryRepresenter

  # ALL stories - not just published and visible
  def scoped(relation)
    relation
  end

end
