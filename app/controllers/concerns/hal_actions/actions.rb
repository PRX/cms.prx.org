module HalActions::Actions
  def index
    respond_with index_collection, index_options
  end

  def show
    respond_with show_resource, show_options
  end

  def create
    create_resource.tap do |resource|
      consume_with_content_type! resource
      authorize resource
      resource.save!
      respond_with root_resource(resource), show_options
    end
  end

  def update
    update_resource.tap do |resource|
      consume_with_content_type! resource
      authorize resource
      resource.save!
      respond_with root_resource(resource), show_options
    end
  end

  def destroy
    destroy_resource.tap do |resource|
      authorize resource
      resource.destroy
      redirect_to destroy_redirect
    end
  end

  private

  def destroy_redirect
    {action: 'index'}
  end

  def index_options
    valid_params_for_action(:index).tap do |options|
      options[:_keys] = options.keys
    end
  end

  def show_options
    valid_params_for_action(:show).tap do |options|
      options[:_keys] = options.keys
      if self.class.resource_representer
        options[:represent_with] = self.class.resource_representer
      end
    end
  end

  def valid_params_for_action(action)
    (params.slice(*self.class.valid_params_list(action)) || {}).tap do |p|
      p[:zoom] = zoom_param if zoom_param
    end
  end

  def zoom_param
    @zoom_param ||= ->() do
      zp = params[:zoom]
      return nil if zp.blank?
      zp.split(',').map(&:strip).compact.sort
    end.call
  end

  def root_resource(resource)
    resource.tap { |res| res.is_root_resource = true }
  end

  # TODO: Remove this method when we upgrade roar-rails
  # Background: https://github.com/apotonick/roar-rails/blob/a109b40/lib/roar/rails/controller_additions.rb#L27
  def consume_with_content_type!(model, options = {})
    type = request.content_type
    format = Mime::Type.lookup(type).try(:symbol)

    if format.blank?
      raise HalActions::Errors::UnsupportedMediaType.new(type)
    end

    parse_method = compute_parsing_method(format)
    representer = prepare_model_for(format, model, options)

    representer.send(parse_method, incoming_string, options)
    model
  end

  module ClassMethods
    attr_accessor :valid_params

    def allow_params(action, *params)
      self.valid_params ||= {}
      valid_params[action.to_sym] = Array(params).flatten
    end

    def valid_params_list(action)
      (valid_params || {})[action.to_sym]
    end
  end
end
