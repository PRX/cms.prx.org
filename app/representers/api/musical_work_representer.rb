# encoding: utf-8

class Api::MusicalWorkRepresenter < Api::BaseRepresenter

  property :id
  property :position
  property :title
  property :artist
  property :label
  property :album
  property :year
  property :excerpt_length, as: :length
end
