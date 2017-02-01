# encoding: utf-8

class User < BaseModel
  acts_as_paranoid

  # DON'T touch the account, as you'll create an infinite loop
  belongs_to :default_account, -> { with_deleted }, class_name: 'Account', foreign_key: 'account_id'

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'UserImage', dependent: :destroy

  has_many :memberships
  has_many :accounts, through: :memberships, source: :account
  has_many :producers

  after_commit :create_individual_account, on: [:create]

  def individual_account
    accounts.where('type = \'IndividualAccount\'').first
  end

  def individual_account=(account)
    prior_account = individual_account
    memberships.create!(account_id: account.id, approved: true, role: 'admin')
    if prior_account
      memberships.where(account_id: prior_account.id).each { |m| memberships.destroy(m) }
    end
  end

  def create_individual_account
    return if individual_account
    User.transaction do
      ia = IndividualAccount.create!(opener_id: id, path: login, status: 'open')
      self.individual_account = ia
      update_attributes!(account_id: individual_account.id)
    end
  end

  def networks
    Network.joins('LEFT OUTER JOIN `network_memberships` on `network_memberships`.`network_id` = `networks`.`id`').
    where(['`networks`.`account_id` in (?) OR `network_memberships`.`account_id` in (?)', accounts.ids, accounts.ids])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def approved_accounts
    Account.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `accounts`.`id`').
      where(['memberships.user_id = ? and memberships.approved is true', id])
  end

  def approved_active_accounts
    approved_accounts.active
  end

  def approved_account_stories
    Story.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `pieces`.`account_id`').
      where(['memberships.user_id = ? and memberships.approved is true', id])
  end

  def approved_account_series
    Series.
      joins('LEFT OUTER JOIN `memberships` ON `memberships`.`account_id` = `series`.`account_id`').
      where(['memberships.user_id = ? and memberships.approved is true', id])
  end
end
