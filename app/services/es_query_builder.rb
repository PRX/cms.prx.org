require 'elasticsearch/dsl'

class ESQueryBuilder
  include Elasticsearch::DSL

  attr_reader :authorization, :params, :query_str, :fields, :fielded_query

  def initialize(args)
    @query_str = args[:query]
    @fields = args[:fields] || default_fields
    @authorization = args[:authorization]
    @params = args[:params]
    @fielded_query = args[:fielded_query]

    build_dsl
  end

  def to_hash
    @dsl.to_hash
  end

  def as_dsl
    @dsl
  end

  def default_operator
    return 'and' unless params && params[:operator]
    params[:operator]
  end

  def default_fields
    fail "You should override default_fields"
  end

  def composite_query_string
    stringify_clauses [query_str, structured_query].select(&:present?)
  end

  def humanized_query_string
    stringify_clauses [query_str, structured_query_humanized].select(&:present?)
  end

  def structured_query
    munge_fielded_query if fielded_query
    FieldedSearchQuery.new(fielded_query)
  end

  private

  def structured_query_humanized
    structured_query.humanized
  end

  def stringify_clauses(clauses)
    if clauses.length == 2
      clauses.map { |c| "(#{c})" }.join(" AND ")
    elsif clauses.length == 1
      clauses[0].to_s
    else
      ""
    end
  end

  # TODO these created_at/within queries are not yet used but here as an example
  # of doing ES date math
  def munge_fielded_query
    # the convert_created_at_to_range and date logic is all preliminary.
    if fielded_query[:created_at].present? && fielded_query[:created_within].present?
      convert_created_at_to_range
    elsif fielded_query[:created_within].present?
      convert_created_at_to_range(true)
    end
    # do not calculate more than once
    fielded_query.delete(:created_within)
  end

  def convert_created_at_to_range(relative_to_now = false)
    ranges = get_date_ranges(fielded_query[:created_at], fielded_query[:created_within])
    return unless ranges
    if relative_to_now
      fielded_query[:created_at] = "[#{ranges[0].iso8601} TO now]"
    else
      fielded_query[:created_at] = "[#{ranges[0].iso8601} TO #{ranges[1].utc.iso8601}]"
    end
  end

  def get_date_ranges(created_at, created_within)
    high_end_range = Time.zone.parse(created_at.to_s) || Time.current
    within_parsed = created_within.match(/^(\d+) (\w+)/)
    if high_end_range && within_parsed
      [high_end_range.utc - within_parsed[1].to_i.send(within_parsed[2]), high_end_range]
    else
      false
    end
  end
  # end TODO example date code

  def build_dsl
    @dsl = Elasticsearch::DSL::Search::Search.new
    # we only need primary key. this cuts down response time by ~70%.
    @dsl.source(["id"])
    add_query
    add_sort
    add_pagination
  end

  def add_query
    searchdsl = self
    bools = build_filters
    @dsl.query = Query.new
    @dsl.query do
      bool do
        must do
          query_string do
            query searchdsl.composite_query_string
            default_operator searchdsl.default_operator
            lenient true
            fields searchdsl.fields
          end
        end
        if bools.any?
          bools.each do |must_filter|
            # this block magic is to make it easy for subclasses to define Filters
            filter_block = must_filter.instance_variable_get(:@block)
            filter(&filter_block)
          end
        end
      end
    end
  end

  # default is no filters. subclasses may add them.
  def build_filters
    []
  end

  def add_sort
    if params && params[:sort]
      @dsl.sort(params[:sort].map { |pair| [pair.split(":")].to_h })
    else
      @dsl.sort(default_sort_params)
    end
  end

  def add_pagination
    calculate_from_size if params && params[:page]
    add_from
    add_size
  end

  def add_from
    if @from
      @dsl.from = @from
    elsif params && params[:from]
      @dsl.from = params[:from].to_i
    else
      @dsl.from = 0
    end
  end

  def add_size
    if @size
      @dsl.size = @size
    elsif params && params[:size]
      @dsl.size = params[:size].to_i
    else
      @dsl.size = default_max_search_results
    end
  end

  def calculate_from_size
    page = params[:page].to_i
    @size ||= (params[:size] || default_max_search_results).to_i
    @from = (page - 1) * @size.to_i
  end
end
