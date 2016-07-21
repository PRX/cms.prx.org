require 'test_helper'

describe ApiFiltering do

  class ApiFilteringTestController < ActionController::Base
    include ApiFiltering

    filter_params :one, :two, :three, :four, :five

    attr_accessor :filter_string

    def params
      { filters: filter_string }
    end
  end

  let(:controller) { ApiFilteringTestController.new }

  it 'parses query params' do
    controller.filter_string = 'one,two=2,three=something,four='
    controller.filters.one.must_equal true
    controller.filters.two.must_equal 2
    controller.filters.three.must_equal 'something'
    controller.filters.four.must_equal ''
  end

  it 'restricts to known params' do
    controller.filter_string = 'one,foo,two,bar'
    controller.filters.one.must_equal true
    controller.filters.two.must_equal true
    err = assert_raises { controller.filters.foo }
    err.must_be_instance_of(ApiFiltering::UnknownFilterError)
    err = assert_raises { controller.filters.whatever }
    err.must_be_instance_of(ApiFiltering::UnknownFilterError)
  end

  it 'provides boolean testers' do
    controller.filter_string = 'one,two=1,three=false,four=,five=0'
    controller.filters.one?.must_equal true
    controller.filters.two?.must_equal true
    controller.filters.three?.must_equal false
    controller.filters.four?.must_equal true
    controller.filters.five?.must_equal true
    assert_raises { controller.filters.whatever? }
  end

  it 'defaults to nil/false for unset filters' do
    controller.filter_string = nil
    controller.filters.one.must_be_nil
    controller.filters.one?.must_equal false
  end

end
