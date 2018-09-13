# encoding: utf-8

require 'active_support/concern'

module ApiSearchable
  extend ActiveSupport::Concern

  def search_query
    params.permit(:q)[:q]
  end

  def search_params
    sparams = {}
    sparams[:page] = params[:page] if params[:page].present?
    sparams[:size] = params[:per] if params[:per].present?
    sparams[:sort] = sorts if respond_to?(:sorts) && sorts.present?
    sparams[:fq] = {}
    sparams
  end

  def rename_sort_param(sort_array, from_name, to_name)
    if sort_array.present?
      sort_array.map do |key_val_obj|
        key_val_obj[to_name] = key_val_obj.delete(from_name) if key_val_obj.key?(from_name)
        key_val_obj
      end
    end
  end
end
