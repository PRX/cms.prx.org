# encoding: utf-8

class UserImage < Image
  belongs_to :user, touch: true
end
