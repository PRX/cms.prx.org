require 'test_helper'

describe ESQueryBuilder do

  it 'requires default fields' do
    err = assert_raises { ESQueryBuilder.new(query: 'foobar') }
    err.message.must_match /override default_fields/
  end

  it 'has sane defaults' do
    hash = ESQueryBuilder.new(fields: ['foo']).to_hash
    hash.keys.sort.must_equal [:_source, :from, :query, :size, :sort]
    hash[:_source].must_equal ['id']
    hash[:size].must_equal 10
    hash[:from].must_equal 0
    hash[:sort].must_equal [{updated_at: {order: :desc, missing: '_last'}}]
    hash[:query].must_equal({bool: {}})
  end

  it 'overrides pagination' do
    hash = ESQueryBuilder.new(fields: ['foo'], params: {size: 1, from: 5}).to_hash
    hash[:size].must_equal 1
    hash[:from].must_equal 5
  end

  it 'overrides sorting' do
    hash = ESQueryBuilder.new(fields: ['foo'], params: {sort: [foo: :asc, foo_at: :asc]}).to_hash
    hash[:sort].must_equal [{foo: :asc, foo_at: {order: :asc, missing: '_first'}}]
  end

  it 'overrides fields' do
    hash = ESQueryBuilder.new(query: 'foobar', fields: ['what', 'ever']).to_hash
    hash[:query][:bool][:must][0][:query_string][:fields].must_equal ['what', 'ever']
  end

  it 'queries for text' do
    hash = ESQueryBuilder.new(query: 'foobar', fields: ['foo']).to_hash
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: 'foobar',
            default_operator: 'and',
            lenient: true,
            fields: ['foo']
          }
        }]
      }
    })
  end

  it 'does a fielded query' do
    hash = ESQueryBuilder.new(fields: ['foo'], params: {fq: {what: 'ever'}}).to_hash
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: 'what:(ever)',
            default_operator: 'and',
            lenient: true,
            fields: ['foo']
          }
        }]
      }
    })
  end

  it 'does both text and fielded query' do
    params = {fq: {what: 'ever'}}
    hash = ESQueryBuilder.new(query: 'foobar', fields: ['foo'], params: params).to_hash
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: '(foobar) AND (what:(ever))',
            default_operator: 'and',
            lenient: true,
            fields: ['foo']
          }
        }]
      }
    })
  end

  it 'searches for nulls' do
    params = {fq: {what: 'ever', maybe: 'NULL', other: nil}}
    hash = ESQueryBuilder.new(fields: ['foo'], params: params).to_hash
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: 'what:(ever)',
            default_operator: 'and',
            lenient: true,
            fields: ['foo']
          }
        }],
        must_not: [
          {exists: {field: 'maybe'}},
          {exists: {field: 'other'}}
        ]
      }
    })
  end

  it 'fields by created_at within a duration' do
    params = {fq: {created_at: '2010-06-01T00:00:00Z', created_within: '3 months'}}
    dsl = ESQueryBuilder.new(fields: 'foo', params: params)
    str = dsl.composite_query_string
    str.must_equal('created_at:[2010-03-01T00:00:00Z TO 2010-06-01T00:00:00Z]')
  end

  it 'fields by created_at relative to now' do
    Timecop.freeze do
      dsl = ESQueryBuilder.new(fields: 'foo', params: {fq: {created_within: '6 months'}})
      str = dsl.composite_query_string
      str.must_equal("created_at:[#{6.months.ago.iso8601} TO now]")
    end
  end
end
