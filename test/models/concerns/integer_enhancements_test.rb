# encoding: utf-8

require 'test_helper'

class EnhancedIntegerModel
  include IntegerEnhancements
end

describe EnhancedIntegerModel do
  let(:model) { EnhancedIntegerModel.new }

  it 'can convert seconds to human-readable durations' do
    0.to_time_string.must_equal '0 seconds'
    10.to_time_string.must_equal '10 seconds'
    100.to_time_string.must_equal '1 minute and 40 seconds'
    1000.to_time_string.must_equal '16 minutes and 40 seconds'
    10000.to_time_string.must_equal '2 hours, 46 minutes, and 40 seconds'

    0.to_time_string_summary.must_equal ':00'
    10.to_time_string_summary.must_equal ':10'
    100.to_time_string_summary.must_equal '01:40'
    1000.to_time_string_summary.must_equal '16:40'
    10000.to_time_string_summary.must_equal '02:46:40'
  end
end
