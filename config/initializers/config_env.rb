# default env vars that may not be set
ENV['CMS_HOST']    ||= 'cms.prx.org'
ENV['FEEDER_HOST'] ||= 'feeder.prx.org'
ENV['ID_HOST']     ||= 'id.prx.org'
ENV['META_HOST']   ||= 'meta.prx.org'
ENV['PRX_HOST']    ||= 'beta.prx.org'

# env_prefix = Rails.env.production? ? '' : (Rails.env + '-')
# env_suffix = Rails.env.development? ? 'dev' : 'org'
