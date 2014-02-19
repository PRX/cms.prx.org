class Api::StoriesController < Api::BaseController

  api_versions :v1

  def show
    respond_with Story.find(params[:id].to_i)
  end

  def index
    @stories = Story.published.order(created_at: :desc).page(params[:page])
    # respond_with PagedCollection.new(@stories, request), represent_with: Api::StoriesRepresenter
    respond_with PagedCollection.new(@stories, request)
  end

end
