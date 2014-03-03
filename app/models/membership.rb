# encoding: utf-8

class Membership < BaseModel

  belongs_to :user, with_deleted: true
  belongs_to :account, with_deleted: true

end
