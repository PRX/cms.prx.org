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

    def method_missing(m, *args, &block)
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
      self.allowed_filter_names = if self.superclass.respond_to?(:allowed_filter_names)
        self.superclass.allowed_filter_names || []
      else
        []
      end
      self.allowed_filter_names = self.allowed_filter_names | args.map(&:to_s).uniq
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
      parts = str.split('=')

      # convert/guess type of known params
      if !filters_map.key?(parts[0])
        next
      elsif parts.count > 1
        if [false, 'false'].include? parts[1]
          filters_map[parts[0]] = false
        elsif [true, 'true'].include? parts[1]
          filters_map[parts[0]] = true
        elsif parts[1] =~ /\A[-+]?\d+\z/
          filters_map[parts[0]] = parts[1].to_i
        else
          filters_map[parts[0]] = parts[1]
        end
      elsif str[-1] == '='
        filters_map[parts[0]] = ''
      else
        filters_map[parts[0]] = true
      end
    end

    FilterParams.new(filters_map)
  end

end
