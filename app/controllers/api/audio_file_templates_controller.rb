# encoding: utf-8

class Api::AudioFileTemplatesController < Api::BaseController
  api_versions :v1

  filter_resources_by :audio_version_template_id
end
