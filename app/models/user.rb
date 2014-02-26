# encoding: utf-8

class User < PRXModel

  belongs_to :default_account, class_name: 'Account', foreign_key: 'account_id', with_deleted: true

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'UserImage'
  has_one :individual_account, foreign_key: 'opener_id'

  has_many :memberships
  has_many :member_accounts, through: :memberships, source: :account
  has_many :producers

  acts_as_paranoid

  def accounts
    Account.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `accounts`.`id`').
      where(['accounts.id = ? OR memberships.user_id = ?', self.individual_account.id, self.id])
  end

  def name
    "#{first_name} #{last_name}"
  end

end
