# encoding: utf-8

class User < PRXModel

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'UserImage'

  has_many :memberships
  has_many :accounts, through: :memberships
  has_many :producers


  acts_as_paranoid

  def name
    "#{first_name} #{last_name}"
  end

end
