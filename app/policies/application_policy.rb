ApplicationPolicy = Struct.new(:token, :resource)

class ApplicationPolicy
  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    update?
  end

  private

  def authorized?(scope)
    if resource_id_was.present? && resource_id_was != resource_id
      token&.authorized?(resource_id, scope) && token.authorized?(resource_id_was, scope)
    else
      token&.authorized?(resource_id, scope)
    end
  end

  def resource_id
    resource&.account_id
  end

  def resource_id_was
    resource&.account_id_was
  end
end
