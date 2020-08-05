require 'test_helper'

describe SeriesQueryBuilder do

  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['cms:read-private'], 456) }
  let(:authorization) { Authorization.new(token) }

  FILTER_PARANOID = {bool: {
    should: [
      {bool: {must_not: [{exists: {field: :deleted_at, _name: :deleted_at_null}}]}},
      {term: {app_version: {value: 'v4', _name: :app_version_v4}}}
    ]
  }}.freeze

  it 'sets sane defaults' do
    dsl = SeriesQueryBuilder.new(query: 'foobar')
    dsl.default_fields.must_equal ['title', 'short_description', 'description']
    dsl.default_sort_params.must_equal [{updated_at: :desc}]
  end

  it 'queries for series' do
    hash = SeriesQueryBuilder.new(query: 'foobar').to_hash
    hash[:query][:bool][:must].must_equal [{
      query_string: {
        query: 'foobar',
        default_operator: 'and',
        lenient: true,
        fields: ['title', 'short_description', 'description']
      }
    }]
  end

  it 'filters for non deleted series' do
    hash = SeriesQueryBuilder.new(query: 'foobar').to_hash
    filters = hash[:query][:bool][:filter]
    filters.count.must_equal(1)
    filters[0].must_equal(FILTER_PARANOID)
  end

  it 'filters for authorized series' do
    hash = SeriesQueryBuilder.new(query: 'foobar', authorization: authorization).to_hash
    filters = hash[:query][:bool][:filter]
    filters.count.must_equal(2)
    filters[0].must_equal({terms: {account_id: [account.id], _name: :authz}})
    filters[1].must_equal(FILTER_PARANOID)
  end

end
