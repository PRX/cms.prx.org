# encoding: utf-8

require 'active_support/concern'

module ApiSearchable
  extend ActiveSupport::Concern

  def search_query
    params.permit(:q)[:q]
  end

  def search_params
    params.permit(:page, :size, :sort, fq: searchable_fields).to_h
  end

  def searchable_fields
    []
  end
end
