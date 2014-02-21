# encoding: utf-8

class Producer < PRXModel

  belongs_to :story, with_deleted: true
  belongs_to :user, with_deleted: true

  acts_as_paranoid

  def full_name
    user.try(:name) || name
  end

end
