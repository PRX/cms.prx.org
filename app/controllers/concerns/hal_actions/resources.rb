module HalActions::Resources
  private

  # action specific resources

  def index_collection
    PagedCollection.new(
      resources,
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    )
  end

  def show_resource
    resource
  end

  def update_resource
    resource
  end

  def create_resource
    resource
  end

  def destroy_resource
    resource
  end

  def resource
    instance_variable_get("@#{resource_name}") || self.resource = begin
      if params[:id]
        filtered(scoped(included(resources_base))).find(params[:id])
      else
        filtered(resources_base).build if request.post?
      end
    end
  end

  def resource=(res)
    instance_variable_set("@#{resource_name}", res)
  end

  def resource_name
    self.class.resource_class.name.underscore
  end

  # Plural resources

  def resources
    instance_variable_get("@#{resources_name}") ||
      self.resources = decorate_query(resources_base)
  end

  def resources=(res)
    instance_variable_set("@#{resources_name}", res)
  end

  def resources_name
    resource_name.pluralize
  end

  def resources_base
    self.class.resource_class.where(nil)
  end

  # Decorations

  def decorate_query(res)
    filtered(paged(sorted(scoped(res))))
  end

  def filtered(arel)
    keys = self.class.resources_params || []
    where_hash = params.slice(*keys)
    if where_hash.key?('story_id')
      where_hash['piece_id'] = where_hash.delete('story_id')
    end
    where_hash = where_hash.permit(where_hash.keys)
    arel = arel.where(where_hash) unless where_hash.blank?
    arel
  end

  def included(res)
    res
  end

  def paged(arel)
    arel.page(params[:page]).per(params[:per])
  end

  def scoped(res)
    res
  end

  def sorted(arel)
    arel.order(id: :desc)
  end

  module ClassMethods
    attr_accessor :resource_class, :resources_params, :resource_representer

    def filter_resources_by(*rparams)
      self.resources_params = rparams
    end

    def represent_with(representer_class)
      self.resource_representer = representer_class
    end

    def resource_class
      @resource_class ||= controller_name.classify.constantize
    end
  end
end
