# encoding: utf-8

require 'active_support/concern'

module PolymorphicResource
  extend ActiveSupport::Concern

  def polymorphic_filtered(polymorphic, arel)
    keys = self.class.resources_params || []
    where_hash = params.slice(*keys)
    if where_hash.key?('story_id')
      where_hash['piece_id'] = where_hash.delete('story_id')
    end

    keys.each do |k|
      if !k.blank? && where_hash.key?(k)
        where_hash["#{polymorphic}_id"] = where_hash.delete(k)
        where_hash["#{polymorphic}_type"] = k.to_s.gsub(/_id$/, '').camelize
      end
    end

    unless where_hash.blank?
      where_hash = where_hash.permit(where_hash.keys)
      arel = arel.where(where_hash)
    end
    arel
  end
end
