require 'test_helper'

describe ApiFiltering do

  class ApiFilteringTestController < ActionController::Base
    include ApiFiltering

    filter_params :one, :two, :three, :four, :five, six: :date, seven: :datetime

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
    controller.filters.six?.must_equal false
    controller.filters.seven?.must_equal false
    assert_raises { controller.filters.whatever? }
  end

  it 'defaults to nil/false for unset filters' do
    controller.filter_string = nil
    controller.filters.one.must_be_nil
    controller.filters.one?.must_equal false
  end

  it 'parses dates' do
    controller.filter_string = 'six=20190203'
    controller.filters.six?.must_equal true
    controller.filters.six.must_equal Date.parse('2019-02-03')
  end

  it 'raises parse errors for dates' do
    controller.filter_string = 'six=bad-string'
    err = assert_raises { puts controller.filters.six }
    err.must_be_instance_of(ApiFiltering::BadFilterValueError)
  end

  it 'parses datetimes' do
    controller.filter_string = 'seven=2019-02-03T01:02:03Z'
    controller.filters.seven?.must_equal true
    controller.filters.seven.must_equal DateTime.parse('2019-02-03T01:02:03Z')
  end

  it 'defaults datetimes to utc' do
    controller.filter_string = 'seven=20190203'
    controller.filters.seven?.must_equal true
    controller.filters.seven.must_equal DateTime.parse('2019-02-03T00:00:00Z')
  end

  it 'raises parse errors for datetimes' do
    controller.filter_string = 'seven=bad-string'
    err = assert_raises { puts controller.filters.seven }
    err.must_be_instance_of(ApiFiltering::BadFilterValueError)
  end

end
