# encoding: utf-8

class User < BaseModel
  acts_as_paranoid

  # DON'T touch the account, as you'll create an infinite loop
  belongs_to :default_account, -> { with_deleted }, class_name: 'Account', foreign_key: 'account_id'

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'UserImage'
  has_one :individual_account, foreign_key: 'opener_id'

  has_many :memberships
  has_many :member_accounts, through: :memberships, source: :account
  has_many :producers

  def accounts
    Account.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `accounts`.`id`').
      where(['accounts.id = ? OR memberships.user_id = ?', individual_account.id, id])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def approved_accounts
    Account.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `accounts`.`id`').
      where(['accounts.id = ? OR (memberships.user_id = ? and memberships.approved is true)', individual_account.id, id])
  end

  def approved_active_accounts
    approved_accounts.active
  end

  def approved_account_stories
    Story.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `pieces`.`account_id`').
      where(['pieces.account_id = ? OR (memberships.user_id = ? and memberships.approved is true)',
             individual_account.id, id])
  end

  def approved_account_series
    Series.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `series`.`account_id`').
      where(['series.account_id = ? OR (memberships.user_id = ? and memberships.approved is true)',
             individual_account.id, id])
  end

end
