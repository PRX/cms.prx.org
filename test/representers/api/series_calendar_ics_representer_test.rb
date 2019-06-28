# encoding: utf-8

require 'test_helper'

require 'series' if !defined?(AudioFile)

describe Api::SeriesCalendarICSRepresenter do

  let(:series) { FactoryGirl.create(:series) }
  let(:representer) { Api::SeriesCalendarICSRepresenter.new(series) }
  let(:ics_repr) { representer.to_object }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create an ics representation' do
    FactoryGirl.create(:story, title: 'foobar', series: series, published_at: nil, released_at: Time.parse('2019-01-01T00:00:00Z'))
    ics_repr.must_match /20190101T000000/
    ics_repr.must_match /foobar/
  end

  it 'can generate a calendar' do
    representer.calendar.events.length.must_equal 2
  end
end
