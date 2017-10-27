# encoding: utf-8

class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include HalApi::RepresentedModel

  def update_file!(name)
    filename_will_change!
    raw_write_attribute(:filename, name)
    save!
  end
end
