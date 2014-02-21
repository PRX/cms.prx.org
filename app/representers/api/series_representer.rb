# encoding: utf-8

class Api::SeriesRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id
  property :title

  property :image, embedded: true, class: SeriesImage, decorator: Api::ImageRepresenter
  
  link :self do
    api_series_path(represented)
  end

end
