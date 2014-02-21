class Api::SeriesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

end
