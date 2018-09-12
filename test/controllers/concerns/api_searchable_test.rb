require 'test_helper'

describe ApiSearchable do

  class ApiSearchableTestController < ActionController::Base
    include ApiSearchable

    attr_accessor :_params
    attr_accessor :_sorts

    def params
      ActionController::Parameters.new(_params)
    end

    def sorts
      _sorts
    end
  end

  let(:controller) { ApiSearchableTestController.new }

  it 'gets the search query' do
    controller.search_query.must_equal nil
    controller._params = {foo: 'bar'}
    controller.search_query.must_equal nil
    controller._params = {foo: 'bar', q: 'stuff'}
    controller.search_query.must_equal 'stuff'
  end

  it 'has pagination search params' do
    controller.search_params.must_equal({fq: {}})
    controller._params = {page: 3, per: 10}
    controller.search_params.must_equal({page: 3, size: 10, fq: {}})
  end

  it 'has sorting search params' do
    controller._sorts = [fld: :desc]
    controller.search_params.must_equal({sort: [fld: :desc], fq: {}})
  end

  it 'renames sort params' do
    sorts = [{fld1: :asc}, {fld2: :desc, fld3: :asc}, {fld4: :asc}]
    controller.rename_sort_param(sorts, :fld3, 'fld3.changed').must_equal([
      {fld1: :asc},
      {fld2: :desc, 'fld3.changed' => :asc},
      {fld4: :asc}
    ])
  end
end
