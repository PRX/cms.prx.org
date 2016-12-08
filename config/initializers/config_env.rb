# default env vars that may not be set
ENV['ID_ROOT'] ||= 'https://id.prx.org/'
ENV['CMS_ROOT'] ||= 'https://cms.prx.org/api/v1/'
ENV['PRX_ROOT'] ||= 'https://beta.prx.org/stories/'
ENV['CRIER_ROOT'] ||= 'https://crier.prx.org/api/v1'

# env_prefix = Rails.env.production? ? '' : (Rails.env + '-')
# env_suffix = Rails.env.development? ? 'dev' : 'org'
