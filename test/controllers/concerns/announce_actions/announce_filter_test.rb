# encoding: utf-8

require 'announce_actions'

describe AnnounceActions::AnnounceFilter do

  let(:controller_class) { Api::TestObjectsController }

  let(:controller) { controller_class.new }

  let(:filter) { AnnounceActions::AnnounceFilter.new('create', {}) }

  before do

    controller_class.class_eval do
      include AnnounceActions
      announce_actions
    end

    clear_messages
  end

  it 'is created with an action and a options' do
    filter.action.must_equal('create')
    filter.options.must_equal({})
  end

  it 'defaults to the min decorator when possible' do
    dc = filter.decorator_class(controller)
    dc.must_equal Api::Min::TestObjectRepresenter
  end

  it 'can use an optional decorator' do
    filter.options[:decorator] = Api::TestObjectRepresenter
    dc = filter.decorator_class(controller)
    dc.must_equal Api::TestObjectRepresenter
  end

  it 'can use an optional action name' do
    filter.resource_action.must_equal('create')
    filter.options[:action] = 'foo'
    filter.resource_action.must_equal('foo')
  end

  it 'tries the action specific resource method' do
    def controller.foo_resource; 'foo'; end
    filter.announce_resource('foo', controller).must_equal 'foo'
  end
end
