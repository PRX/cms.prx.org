class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  def resources
    @stories ||=  Story.published.order(created_at: :desc).page(params[:page])
  end

end
