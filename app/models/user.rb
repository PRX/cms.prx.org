# encoding: utf-8

class User < PRXModel

  has_many :memberships
  has_many :accounts, through: :memberships
  has_many :producers

  acts_as_paranoid

  def name
    "#{first_name} #{last_name}"
  end

end
