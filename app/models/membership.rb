# encoding: utf-8

class Membership < BaseModel
  belongs_to :user, -> { with_deleted }, touch: true
  belongs_to :account, -> { with_deleted }, touch: true

  scope :approved, -> { where(approved: true) }

  after_commit :update_user_default_account, on: [:destroy]

  def update_user_default_account
    if user.default_account == account
      user.update_attributes!(account_id: user.individual_account.id)
    end
  end
end
