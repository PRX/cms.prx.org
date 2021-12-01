CarrierWave.configure do |config|
  config.storage         = :fog
  config.fog_directory   = ENV['AWS_BUCKET']
  config.fog_public      = false
  config.fog_attributes  = {}

  if (ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'])
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region:                ENV['AWS_REGION'] || 'us-east-1',
      path_style:            true
    }
  else
    config.fog_credentials = {
      provider:              'AWS',
      use_iam_profile:       true,
      region:                ENV['AWS_REGION'] || 'us-east-1',
      path_style:            true
    }
  end

  config.remove_previously_stored_files_after_update = false
end
