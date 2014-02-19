class Api::LicensesController < Api::BaseController

  api_versions :v1

  def show
    respond_with License.find(params[:id].to_i)
  end

end
