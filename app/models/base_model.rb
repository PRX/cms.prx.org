# encoding: utf-8

class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include RepresentedModel
  include Announce::Publisher

  def id_from_url(url)
    Rails.application.routes.recognize_path(url)[:id]
  end

  def update_file!(name)
    filename_will_change!
    raw_write_attribute(:filename, name)
    save!
  end
end
