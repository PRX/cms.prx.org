# encoding: utf-8

class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include ActionBack::RouteBack

  # this concept is used in result set, perhaps doesn't belong in model itself
  # consider if there is a better way to do this - decorate model instead?
  attr_accessor :is_root_resource

  def is_root_resource
    !!@is_root_resource
  end

  def show_curies
    is_root_resource
  end

  def update_file!(name)
    filename_will_change!
    raw_write_attribute(:filename, name)
    save!
  end
end
