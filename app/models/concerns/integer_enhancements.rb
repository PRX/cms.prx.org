# encoding: utf-8

module IntegerEnhancements

  def positive?
      self > 0
  end

  def negative?
      self < 0
  end

  def to_time_string
    time_duration_in_words(self)
  end

  def to_time_string_summary
    time_duration_summary(self)
  end

  def time_duration_in_words(seconds = 0)
    return '0 seconds' if seconds <= 0
    time_values = time_duration(seconds)
    [:hour, :minute, :second].inject([]) do |words, unit|
      if (time_values[unit]).positive?
        units_text = time_values[unit] == 1 ? unit.to_s : unit.to_s.pluralize
        words << "#{time_values[unit]} #{units_text}"
      end
      words
    end.to_sentence
  end

  def time_duration_summary(seconds = 0)
    return ':00' if seconds <= 0
    time_values = time_duration(seconds)
    last_zero = true
    nums = [:hour, :minute, :second].collect do |unit|
      if last_zero &&  (time_values[unit]).zero?
        nil
      else
        last_zero = false
        format('%02d', time_values[unit])
      end
    end.compact
    if nums.size > 1
      nums.join(':')
    else
      ":#{nums[0]}"
    end
  end

  def time_duration(seconds)
    return { second: 0 } if seconds <= 0
    secs = seconds
    [[:hour, 3600], [:minute, 60], [:second, 1]].inject({}) do |values, each|
      unit,size = each
      values[unit] = ((secs <= 0) ? 0 : (secs / size))
      secs = (secs <= 0) ? 0 : (secs % size)
      values
    end
  end
end

class Integer
  include IntegerEnhancements
end
