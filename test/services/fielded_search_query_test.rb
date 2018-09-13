require 'test_helper'

describe FieldedSearchQuery do

  it 'knows if it exists' do
    FieldedSearchQuery.new(nil).present?.must_equal false
    FieldedSearchQuery.new({}).present?.must_equal false
    FieldedSearchQuery.new(something: nil).present?.must_equal false
    FieldedSearchQuery.new(something: 'value').present?.must_equal true
  end

  it 'joins multiple clauses' do
    query = FieldedSearchQuery.new(field_a: '123', field_b: '456')
    query.to_h.must_equal({'field_a' => '123', 'field_b' => '456'})
    query.to_s.must_equal 'field_a:(123) field_b:(456)'
  end

  it 'humanizes clauses' do
    query = FieldedSearchQuery.new(field_a: 'what', field_b: 'ever').humanized
    query.to_h.must_equal({'Field A' => 'what', 'Field B' => 'ever'})
    query.to_s.must_equal 'Field A:(what) Field B:(ever)'
  end

  it 'ignores blank clauses' do
    query = FieldedSearchQuery.new(a: nil, b: '', c: '*', d: 'NULL', e: 123)
    query.to_h.must_equal({'e' => 123})
    query.to_s.must_equal 'e:(123)'
  end

end
