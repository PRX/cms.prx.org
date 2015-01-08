describe HalActions do

  class Foo
    include ActiveModel::Model

    attr_accessor :id, :is_root_resource, :updated_at
    cattr_accessor :_id

    self._id = 1

    def self.find(*args)
      Foo.new.tap { |f|
        f.id = _id
        self._id += 1
        f.updated_at = DateTime.parse('1970-01-01 00:01:00')
      }
    end

    def self.inject(*args, &block)
      self._id = 1
      [find, find].inject(*args, &block)
    end

    def self.order(*args); self; end
    def self.page(*args); self; end
    def self.per(*args); self; end
  end

  class FooRepresenter
  end

  class FoosController < ActionController::Base
    include HalActions
    include Pundit

    cattr_accessor :_caches_action

    attr_accessor :_respond_with

    def params
      ActionController::Parameters.new({ action: 'update' })
    end

    def current_user
      FactoryGirl.create(:user)
    end

    def respond_with(*args)
      self._respond_with = args
    end

    def self.caches_action(action, options={})
      self._caches_action ||= {}
      self._caches_action[action] = options
    end
  end

  let (:controller) { FoosController.new }
  let (:account) { create(:account) }

  describe 'instance methods' do

    it 'determines resource id for caching' do
      controller.show_cache_path.must_equal 60
    end

    it 'determines the resources id for caching' do
      controller.index_cache_path.must_equal "c/foos/3-60"
    end

    it 'responds to show request' do
      controller.show
      controller._respond_with.wont_be_nil
      controller._respond_with.first.must_be_instance_of Foo
      controller._respond_with.last[:_keys].must_equal []
    end

    it 'can adds paging to resources query' do
      arel = FoosController.new.with_paging(Account.where('id is not null'))
      arel.to_sql.must_match /LIMIT 10 OFFSET 0/
    end

    it 'authorizes the resource' do
      controller.stub(:authorize, true) do
        assert_send([controller, :authorize, account])
      end
    end
  end

  describe 'class methods' do

    it 'determines class for resource' do
      FoosController.resource_class.must_equal Foo
    end

    it 'can specify filter params' do
      FoosController.filter_resources_by(:bar_id)
      FoosController.resources_params.must_equal [:bar_id]
    end

    it 'can specify representer' do
      FoosController.represent_with(FooRepresenter)
      FoosController.resource_representer.must_equal FooRepresenter
    end

    it 'specify allowed params for an action' do
      FoosController.allow_params :index, [:page, :per, :zoom]
      FoosController.valid_params.must_equal :index => [:page, :per, :zoom]
      FoosController.valid_params_list(:index).must_equal [:page, :per, :zoom]
    end

    it 'sets default cache options' do
      FoosController.cache_options.must_equal({compress: true, expires_in: 1.hour, race_condition_ttl: 30})
    end

    it 'caches api actions' do
      FoosController.cache_api_action(:index, bar: true)
      FoosController._caches_action[:index][:bar].must_equal true
    end
  end

end
