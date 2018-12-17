# encoding: utf-8

class IndividualAccount < Account
  before_validation :use_login_as_path
  after_create :create_membership

  validates :opener, presence: true

  def name
    opener.try(:name)
  end

  def short_name
    opener.try(:first_name)
  end

  def path
    opener.try(:login)
  end

  def image
    opener.try(:image)
  end

  def address
    opener.try(:address)
  end

  def description
    opener.try(:bio)
  end

  def self.policy_class
    IndividualAccountPolicy
  end

  private

  def create_membership
    memberships.create!(user_id: opener.id, approved: true, role: 'admin')
  end

  def use_login_as_path
    assign_attributes(path: opener.login)
  end
end
