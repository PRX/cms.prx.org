# encoding: utf-8

class SeriesImage < Image
  porter_callbacks sqs: CALLBACK_QUEUE
  belongs_to :series, touch: true
end
