# encoding: utf-8

class AccountImage < Image
  belongs_to :account, touch: true
  porter_callbacks sqs: CALLBACK_QUEUE
end
