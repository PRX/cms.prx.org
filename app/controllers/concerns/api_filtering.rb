# encoding: utf-8

require 'active_support/concern'

module ApiFiltering
  extend ActiveSupport::Concern

  class UnknownFilterError < NoMethodError
  end

  class FilterParams < OpenStruct
    def initialize(filters = {})
      @filters = filters.with_indifferent_access
    end

    def method_missing(m, *args, &_block)
      if @filters.key?(m) && args.empty?
        @filters[m]
      elsif m.to_s[-1] == '?' && args.empty? && @filters.key?(m.to_s.chop)
        !!@filters[m.to_s.chop]
      else
        raise UnknownFilterError.new("Unknown filter param '#{m}'")
      end
    end
  end

  module ClassMethods
    attr_accessor :allowed_filter_names

    def filter_params(*args)
      self.allowed_filter_names = args.map(&:to_s).uniq
      if superclass.respond_to?(:allowed_filter_names)
        self.allowed_filter_names |= (superclass.allowed_filter_names || [])
      end
    end
  end

  def filters
    @filters ||= parse_filters_param
  end

  private

  def parse_filters_param
    filters_map = {}

    # set nils
    self.class.allowed_filter_names.each do |name|
      filters_map[name] = nil
    end

    # parse query param
    (params[:filters] || '').split(',').each do |str|
      name, value = str.split('=', 2)
      next unless filters_map.key?(name)

      # convert/guess type of known params
      filters_map[name] =
        if value.nil?
          true
        elsif value.blank?
          ''
        elsif [false, 'false'].include? value
          false
        elsif [true, 'true'].include? value
          true
        elsif value =~ /\A[-+]?\d+\z/
          value.to_i
        else
          value
        end
    end
    FilterParams.new(filters_map)
  end

end
