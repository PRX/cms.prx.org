require 'test_helper'

describe StoryQueryBuilder do

  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['cms:read-private cms:story'], 456) }
  let(:authorization) { Authorization.new(token) }

  # sorry... ES filters can be a bit ugly
  FILTER_PUBLISHED = {range: {published_at: {lte: 'now', _name: :published}}}.freeze
  FILTER_NETWORK_VISIBLE = {bool: {
    must_not: [{exists: {field: :network_only_at, _name: :network_visible}}]
  }}.freeze
  FILTER_SERIES_APPROVED = {bool: {
    must_not: [{
      term: {'series.subscription_approval_status' =>
        {value: 'PRX Approved', _name: :prx_series_approved}}
    }]
  }}.freeze
  FILTER_SERIES_NOT_SUB_ONLY = {bool: {
    must_not: [{exists: {field: 'series.subscriber_only_at', _name: :series_subscriber_only_at}}]
  }}.freeze
  FILTER_SERIES_VISIBLE = {bool: {
    should: [FILTER_SERIES_APPROVED, FILTER_SERIES_NOT_SUB_ONLY]
  }}.freeze
  FILTER_PARANOID = {bool: {
    should: [
      {bool: {must_not: [{exists: {field: :deleted_at, _name: :deleted_at_null}}]}},
      {term: {app_version: {value: 'v4', _name: :app_version_v4}}}
    ]
  }}.freeze

  it 'sets sane defaults' do
    dsl = StoryQueryBuilder.new(query: 'foobar')
    dsl.default_fields.must_equal ['title', 'short_description', 'description']
    dsl.default_sort_params.must_equal [{published_at: :desc, updated_at: :desc}]
  end

  it 'queries for stories' do
    hash = StoryQueryBuilder.new(query: 'foobar').to_hash
    hash[:query][:bool][:must].must_equal [{
      query_string: {
        query: 'foobar',
        default_operator: 'and',
        lenient: true,
        fields: ['title', 'short_description', 'description']
      }
    }]
  end

  it 'filters for public stories' do
    hash = StoryQueryBuilder.new(query: 'foobar').to_hash
    filters = hash[:query][:bool][:filter]
    filters.count.must_equal(4)
    filters[0].must_equal(FILTER_PUBLISHED)
    filters[1].must_equal(FILTER_NETWORK_VISIBLE)
    filters[2].must_equal(FILTER_SERIES_VISIBLE)
    filters[3].must_equal(FILTER_PARANOID)
  end

  it 'filters for authorized stories' do
    hash = StoryQueryBuilder.new(query: 'foobar', authorization: authorization).to_hash
    filters = hash[:query][:bool][:filter]
    filters.count.must_equal(2)
    filters[0].must_equal({terms: {account_id: [account.id], _name: :authz}})
    filters[1].must_equal(FILTER_PARANOID)
  end

end
