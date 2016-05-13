# encoding: utf-8

class Schedule < BaseModel
  belongs_to :series, touch: true
end
