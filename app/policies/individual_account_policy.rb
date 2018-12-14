class IndividualAccountPolicy < AccountPolicy
  def create?
    binding.pry
    # An account without a membership to an Individual Account
    token.present? && !IndividualAccount.
      joins(:memberships).
      find_by('memberships.user_id': token.user_id)
  end
end
