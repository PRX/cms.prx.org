# encoding: utf-8

module Storied
  extend ActiveSupport::Concern

  def public_stories
    stories.public_stories
  end
end
