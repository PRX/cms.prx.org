# encoding: utf-8

require 'active_support/concern'

module ApiFiltering
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :allowed_filter_names
      class_attribute :allowed_filter_types
    end
  end

  class UnknownFilterError < NoMethodError
  end
  class BadFilterValueError < HalApi::Errors::ApiError
    def initialize(msg)
      super(msg, 400)
    end
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
    def filter_params(*args)
      self.allowed_filter_names = []
      self.allowed_filter_types = {}
      (args || []).map do |arg|
        if arg.is_a? Hash
          arg.to_a.each { |key, val| add_filter_param(key.to_s, val.to_s) }
        else
          add_filter_param(arg.to_s)
        end
      end
    end

    private

    def add_filter_param(name, type = nil)
      unless self.allowed_filter_names.include? name
        self.allowed_filter_names << name
        self.allowed_filter_types[name] = type unless type.nil?
      end
    end
  end

  def filters
    @filters ||= parse_filters_param
  end

  private

  def parse_filters_param
    filters_map = {}
    filters = self.class.allowed_filter_names
    force_types = self.class.allowed_filter_types

    # set nils
    filters.each do |name|
      filters_map[name] = nil
    end

    # parse query param
    (params[:filters] || '').split(',').each do |str|
      name, value = str.split('=', 2)
      next unless filters_map.key?(name)

      # convert/guess type of known params
      filters_map[name] =
        if force_types[name] == 'date'
          parse_date(value)
        elsif force_types[name] == 'datetime'
          parse_datetime(value)
        elsif value.nil?
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

  def parse_date(str)
    Date.parse(str)
  rescue ArgumentError
    raise BadFilterValueError.new "Invalid filter date: '#{str}'"
  end

  def parse_datetime(str)
    DateTime.parse(str)
  rescue ArgumentError
    raise BadFilterValueError.new "Invalid filter datetime: '#{str}'"
  end
end
