# encoding: utf-8
require 'hash_serializer'

class StoryDistribution < BaseModel
  belongs_to :distribution
  belongs_to :story, -> { with_deleted }, class_name: 'Story', foreign_key: 'piece_id', touch: true
  serialize :properties, HashSerializer

  def distribute!
    # no op for the super class
  end

  def kind
    (type || 'StoryDistribution').safe_constantize.model_name.element.sub(/_distribution$/, '')
  end

  def kind=(k)
    child_class = "StoryDistributions::#{k.titleize}Distribution".safe_constantize if k
    if child_class
      self.type = child_class.name
    end
  end

  def self.class_for_kind(k)
    child_class = "StoryDistributions::#{k.titleize}Distribution".safe_constantize if k
    child_class || Distribution
  end

  def self.policy_class
    StoryAttributePolicy
  end
end
