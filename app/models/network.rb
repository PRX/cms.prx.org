# encoding: utf-8

class Network < BaseModel
  include Storied

  belongs_to :account

  has_many :stories, -> { published.series_visible.order(published_at: :desc) }

  def self.policy_class
    AccountablePolicy
  end
end
