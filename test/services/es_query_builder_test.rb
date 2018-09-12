require 'test_helper'

describe ESQueryBuilder do

  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member'], 456) }
  let(:authorization) { Authorization.new(token) }
  let(:unauth_account) { create(:account) }

  it 'requires default fields' do
    err = assert_raises { ESQueryBuilder.new(query: 'foobar') }
    err.message.must_match /override default_fields/
  end

  it 'creates a query hash' do
    dsl = ESQueryBuilder.new(
      query: 'foobar',
      fields: ['what', 'ever'],
      params: {from: 1, size: 5, fq: {something: '123'}}
    )
    hash = dsl.to_hash

    hash.keys.sort.must_equal [:_source, :from, :query, :size, :sort]
    hash[:_source].must_equal ['id']
    hash[:size].must_equal 5
    hash[:from].must_equal 1
    hash[:sort].must_equal [{updated_at: {order: :desc, missing: '_last'}}]
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: '(foobar) AND (something:(123))',
            default_operator: 'and',
            lenient: true,
            fields: ['what', 'ever']
          }
        }]
      }
    })
  end

  it 'can have no fielded query' do
    dsl = ESQueryBuilder.new(query: 'foobar', fields: ['foo'], params: {sort: [created_at: :asc]})
    hash = dsl.to_hash

    hash.keys.sort.must_equal [:_source, :from, :query, :size, :sort]
    hash[:_source].must_equal ['id']
    hash[:size].must_equal 10
    hash[:from].must_equal 0
    hash[:sort].must_equal [{created_at: {order: :asc, missing: '_first'}}]
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

  it 'can have only a fielded query' do
    dsl = ESQueryBuilder.new(fields: ['foo'], params: {fq: {something: '123'}})
    hash = dsl.to_hash

    hash.keys.sort.must_equal [:_source, :from, :query, :size, :sort]
    hash[:_source].must_equal ['id']
    hash[:size].must_equal 10
    hash[:from].must_equal 0
    hash[:sort].must_equal [{updated_at: {order: :desc, missing: '_last'}}]
    hash[:query].must_equal({
      bool: {
        must: [{
          query_string: {
            query: 'something:(123)',
            default_operator: 'and',
            lenient: true,
            fields: ['foo']
          }
        }]
      }
    })
  end

  it 'can have no query' do
    dsl = ESQueryBuilder.new(fields: ['foo'], params: {sort: [foo: :desc]})
    hash = dsl.to_hash

    hash.keys.sort.must_equal [:_source, :from, :query, :size, :sort]
    hash[:_source].must_equal ['id']
    hash[:size].must_equal 10
    hash[:from].must_equal 0
    hash[:sort].must_equal [{foo: :desc}]
    hash[:query].must_equal({bool: {}})
  end
end
