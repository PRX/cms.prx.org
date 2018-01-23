# encoding: utf-8
require 'hash_serializer'

class Distribution < BaseModel
  belongs_to :distributable, polymorphic: true, touch: true

  has_many :story_distributions
  has_many :distribution_templates, dependent: :destroy, autosave: true
  has_many :audio_version_templates, through: :distribution_templates
  serialize :properties, HashSerializer

  def self.check_published!(data = nil)
    data ||= {}
    from_secs = (data[:from_secs] || '60').to_i
    to_secs = (data[:to_secs] || '3600').to_i

    recently_published_stories(from_secs, to_secs).each do |story|
      story.distributions.each do |dist|
        dist.distribute! if !dist.distributed?
        dist.publish! if !dist.published?
      end
    end
  end

  def self.recently_published_stories(from_secs, to_secs)
    Story.where(
      '`published_at` <= ? AND `published_at` >= ?',
      from_secs.seconds.ago,
      to_secs.seconds.ago
    ).joins(:distributions).distinct
  end

  def set_template_ids(ids)
    keep = []
    Array(ids).map(&:to_i).uniq.each do |avt_id|
      if distribution_templates.exists?(audio_version_template_id: avt_id)
        keep << avt_id
      elsif avt = AudioVersionTemplate.where(id: avt_id, series_id: distributable_id).first
        keep << avt_id
        distribution_templates.build(audio_version_template: avt)
      end
    end
    distribution_templates.where(['audio_version_template_id not in (?)', keep]).delete_all
  end

  def audio_version_template
    audio_version_templates.first
  end

  def audio_version_template=(t)
    audio_version_templates.clear
    audio_version_templates << t
  end

  def audio_version_template_id
    audio_version_template.try(:id)
  end

  def audio_version_template_id=(tid)
    self.audio_version_template = AudioVersionTemplate.find_by_id(tid)
  end

  def distribute!
    # no op for the super class
  end

  # default to the generic distro, override in subclass
  def story_distribution_class
    StoryDistribution
  end

  def create_story_distribution(story)
    story_distribution_class.create(distribution: self, story: story).tap(&:distribute!)
  end

  def owner
    distributable
  end

  def account
    if owner.is_a?(Account)
      owner
    else
      owner.try(:account)
    end
  end

  def kind
    (type || 'Distribution').safe_constantize.model_name.element.sub(/_distribution$/, '')
  end

  def kind=(k)
    child_class = "Distributions::#{k.titleize}Distribution".safe_constantize if k
    if child_class
      self.type = child_class.name
    end
  end

  def self.class_for_kind(k)
    child_class = "Distributions::#{k.titleize}Distribution".safe_constantize if k
    child_class || Distribution
  end

  def self.policy_class
    AccountablePolicy
  end
end
