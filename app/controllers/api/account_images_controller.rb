# encoding: utf-8

class Api::AccountImagesController < Api::BaseController

  api_versions :v1

  filter_resources_by :account_id

  represent_with Api::ImageRepresenter

end
