require 'shoryuken'

config_file = File.join(Rails.root, 'config', 'shoryuken.yml')
Shoryuken::EnvironmentLoader.load(config_file: config_file)
