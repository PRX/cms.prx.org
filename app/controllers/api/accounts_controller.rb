class Api::AccountsController < Api::BaseController

  api_versions :v1

  filter_resources_by :user_id

end
