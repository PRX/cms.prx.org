require 'paranoia'

class ActiveRecord::Base
  def self.belongs_to_with_deleted(target, scope=nil, options={})
    scope, options = nil, scope if scope.kind_of? Hash
    if options.delete(:with_deleted)
      column = :deleted_at
      new_scope = -> (o) {
        (scope ? scope.call(o) : self).unscope(where: column) }
      belongs_to_without_deleted(target, new_scope, options).tap do
        column = reflect_on_association(target).klass.paranoia_column
      end
    else
      belongs_to_without_deleted(target, scope, options)
    end
  end

  class << self; alias_method_chain :belongs_to, :deleted; end
end
