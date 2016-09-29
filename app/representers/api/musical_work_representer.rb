# encoding: utf-8

class Api::MusicalWorkRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :position
  property :title
  property :artist
  property :label
  property :album
  property :year
  property :duration

  def self_url(musical_work)
    api_story_musical_work_path(musical_work.story, musical_work)
  end
end
