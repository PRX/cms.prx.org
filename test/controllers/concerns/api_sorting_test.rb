require 'test_helper'

describe ApiSorting do

  class ApiSortingTestController < ActionController::Base
    include ApiSorting

    sort_params default: { one: :desc }, allowed: [:one, :two, :three, :four, :five]

    attr_accessor :sort_string

    def params
      { sorts: sort_string }
    end
  end

  let(:controller) { ApiSortingTestController.new }

  before do
    controller.sort_string = 'one,two:asc,three:desc,four:,five:up,six'
  end

  it 'sets a default array of sorts' do
    controller.class.default_sort.must_equal [{ one: :desc }]
  end

  it 'parses query params' do
    controller.sorts.count.must_equal 4
  end

  it 'defaults sorts to desc' do
    one = controller.sorts[0]
    one.keys.count.must_equal 1
    one.keys[0].must_equal 'one'
    one['one'].must_equal 'desc'
  end

  it 'can specify asc order' do
    two = controller.sorts[1]
    two.keys.count.must_equal 1
    two.keys[0].must_equal 'two'
    two['two'].must_equal 'asc'
  end

  it 'can specify desc order' do
    three = controller.sorts[2]
    three.keys.count.must_equal 1
    three.keys[0].must_equal 'three'
    three['three'].must_equal 'desc'
  end

  it 'defaults to desc if it ends with a semi-colon' do
    four = controller.sorts[3]
    four.keys.count.must_equal 1
    four.keys[0].must_equal 'four'
    four['four'].must_equal 'desc'
  end

  it 'ignores sorts that are not asc or desc' do
    five = controller.sorts[4]
    five.must_be_nil
  end

  it 'ignores sorts that are not declared' do
    controller.sorts[5].must_be_nil
  end

  it 'sorted adds orders to resources arel' do
    sorts = [{ 'one' => 'desc' }, { 'two' => 'asc' }, { 'three' => 'desc' }, { 'four' => 'desc' }]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    result.orders.must_equal sorts
  end

  it 'sorted adds default orders to resources arel' do
    controller.sort_string = nil
    sorts = [{ one: :desc }]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    result.orders.must_equal sorts
  end
end
