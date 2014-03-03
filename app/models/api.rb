# encoding: utf-8

class Api

  extend ActiveModel::Naming

  def self.version(version)
    new(version)
  end

  attr_accessor :version

  def initialize(version)
    @version = version
  end

end
