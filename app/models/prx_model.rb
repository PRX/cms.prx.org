# encoding: utf-8

class PRXModel < ActiveRecord::Base
  self.abstract_class = true

  def update_file!(name)
    filename_will_change!
    raw_write_attribute(:filename, name)
    save!
  end

end
