require 'elasticsearch/dsl'

class StoryQueryBuilder
  include Elasticsearch::DSL

  attr_reader :current_user, :params, :query_str, :fields

  def initialize(args)
    @query_str = args[:query]
    @fields = args[:fields] || default_fields
    @current_user = args[:current_user]
    @params = args[:params]

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
    ['title', 'short_description', 'description']
  end

  def apply_authz?
    current_user
  end

  def apply_published_filter?
    apply_authz?
  end

  def composite_query_string
    stringify_clauses [query_str].select(&:present?)
  end

  def humanized_query_string
    stringify_clauses [query_str].select(&:present?)
  end

  private

  def stringify_clauses(clauses)
    if clauses.length == 2
      clauses.map { |c| "(#{c})" }.join(" AND ")
    elsif clauses.length == 1
      clauses[0].to_s
    else
      ""
    end
  end

  def munge_fielded_params(fielded)
    if fielded[:created_at].present? && fielded[:created_within].present?
      convert_created_at_to_range(fielded)
    elsif fielded[:created_within].present?
      convert_created_at_to_range(fielded, true)
    end
    # do not calculate more than once
    fielded.delete(:created_within)
  end

  def convert_created_at_to_range(fielded, relative_to_now = false)
    ranges = get_date_ranges(fielded[:created_at], fielded[:created_within])
    return unless ranges
    if relative_to_now
      fielded[:created_at] = "[#{ranges[0].iso8601} TO now]"
    else
      fielded[:created_at] = "[#{ranges[0].iso8601} TO #{ranges[1].utc.iso8601}]"
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

  def build_dsl
    @dsl = Elasticsearch::DSL::Search::Search.new
    # we only need primary key. this cuts down response time by ~70%.
    @dsl.source(["id"])
    add_query
    add_filter
    add_sort
    add_pagination
  end

  def add_query
    searchdsl = self
    @dsl.query = Query.new
    @dsl.query do
      multi_match do
        query searchdsl.composite_query_string
        operator searchdsl.default_operator
        type 'cross_fields'
        fields searchdsl.fields
      end
    end
  end

  def add_filter
    bools = build_filters
    if bools.any?
      @dsl.filter = Filter.new
      @dsl.filter.bool do
        bools.each do |must_filter|
          filter_block = must_filter.instance_variable_get(:@block)
          must(&filter_block)
        end
      end
    end
  end

  def build_filters
    bools = []
    if apply_published_filter?
      bools.push published_filter
    end
    if apply_authz?
      bools.push authz_filter
    end
    bools
  end

  def published_filter
    searchdsl = self
    Filter.new do
      term published: true
    end
  end

  def authz_filter
    searchdsl = self
    Filter.new do
      term account_id: searchdsl.current_user.account_ids
    end
  end

  def add_sort
    if params && params[:sort]
      @dsl.sort(params[:sort].map { |pair| [pair.split(":")].to_h })
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
      @dsl.size = Story::MAX_SEARCH_RESULTS
    end
  end

  def calculate_from_size
    page = params[:page].to_i
    @size ||= (params[:size] || Story::MAX_SEARCH_RESULTS).to_i
    @from = (page - 1) * @size.to_i
  end
end
