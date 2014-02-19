# encoding: utf-8

class Api::LicenseRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :website_usage
  property :allow_edit
  property :additional_terms

  link :self do 
    api_story_license_path(represented.story, represented)
  end

end
