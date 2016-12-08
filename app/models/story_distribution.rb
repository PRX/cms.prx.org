# encoding: utf-8
require 'hash_serializer'

class StoryDistribution < BaseModel
  belongs_to :distribution
  belongs_to :story
  serialize :properties, HashSerializer

  def distribute
    # no op for the super class
  end
end
