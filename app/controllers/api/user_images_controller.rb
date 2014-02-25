class Api::UserImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :user_id

  represent_with Api::ImageRepresenter

end
