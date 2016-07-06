# encoding: utf-8

class SeriesImage < Image
  belongs_to :series, touch: true
end
