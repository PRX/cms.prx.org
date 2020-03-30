# encoding: utf-8

class UserImage < Image
  porter_callbacks sqs: CALLBACK_QUEUE
  belongs_to :user, touch: true
end
