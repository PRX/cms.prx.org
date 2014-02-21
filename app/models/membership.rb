# encoding: utf-8

class Membership < PRXModel

  belongs_to :user, with_deleted: true
  belongs_to :account, with_deleted: true

end
