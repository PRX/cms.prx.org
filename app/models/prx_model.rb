# encoding: utf-8

class PRXModel < ActiveRecord::Base
  self.abstract_class = true

  # def self.store_dir_name
  #   self.to_s.pluralize.underscore
  # end
end
