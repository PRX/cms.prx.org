# encoding: utf-8
require 'hash_serializer'

class StoryDistribution < ActiveRecord::Base
  belongs_to :distribution
  belongs_to :story
  serialize :properties, HashSerializer
end
