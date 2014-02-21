class Api::AudioFilesController < Api::BaseController

  api_versions :v1

  filter_resources_by :story_id, :audio_version_id

end
