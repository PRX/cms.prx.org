# encoding: utf-8

class Network < BaseModel
  belongs_to :account

  has_many :stories, -> { where('published_at is not null and network_only_at is null').order(published_at: :desc) }
  has_many :all_stories, -> { where('published_at is not null').order(published_at: :desc) }, foreign_key: 'network_id', class_name: 'Story'

  def self.policy_class
    AccountablePolicy
  end
end
