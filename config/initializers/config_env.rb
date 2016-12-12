# default env vars that may not be set
ENV['CMS_HOST']    ||= 'cms.prx.org'
ENV['FEEDER_HOST'] ||= 'feeder.prx.tech'
ENV['ID_HOST']     ||= 'id.prx.org'
ENV['META_HOST']   ||= 'meta.prx.org'
ENV['PRX_HOST']    ||= 'www.prx.org'

# env_prefix = Rails.env.production? ? '' : (Rails.env + '-')
# env_suffix = Rails.env.development? ? 'dev' : 'org'
