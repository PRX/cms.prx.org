class Api::StoriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :series_id, :account_id

  def resource
    @story ||= Story.published.find_by_id(params[:id])
  end

  def resources
    @stories ||=  Story.published.order(created_at: :desc).includes({audio_versions: [:audio_files]}, {account: [:image, :address, {opener:[:image]}]}, {series:[:image, :account]}, :images, :license).page(params[:page])
  end

end
