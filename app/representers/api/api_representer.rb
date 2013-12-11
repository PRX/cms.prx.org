class Api::ApiRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :version

  link :self do
    api_root_path(represented.version)
  end

  links :stories do
    [ { profile: 'http://meta.prx.org/model/story', href: api_stories_path(api_version: represented.version)},
      { href: api_story_path(represented.version, 632).sub('632', '{id}'), profile: 'http://meta.prx.org/model/story' } ]
  end
end