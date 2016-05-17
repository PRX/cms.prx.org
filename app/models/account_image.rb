# encoding: utf-8

class AccountImage < Image
  belongs_to :account, touch: true
end
