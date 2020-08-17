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

  def authorized?(scope, resource_id_method_name = :account_id)
    resource_id = resource.public_send(resource_id_method_name)
    resource_id_was = resource.public_send("#{resource_id_method_name}_was")

    if resource_id_was.present? && resource_id_was != resource_id
      token&.authorized?(resource_id, scope) && token.authorized?(resource_id_was, scope)
    else
      token&.authorized?(resource_id, scope)
    end
  end
end
