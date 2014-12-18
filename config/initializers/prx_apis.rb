require 'media_monster_client'

MediaMonsterClient.host    = ENV['FIXER_HOST']
MediaMonsterClient.port    = 80
MediaMonsterClient.version = 'v1'
MediaMonsterClient.key     = ENV['FIXER_KEY']
MediaMonsterClient.secret  = ENV['FIXER_SECRET']
