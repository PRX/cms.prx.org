# encoding: utf-8
require 'announce_actions'

describe AnnounceActions::AnnounceFilter do
  let(:resource) { TestObject.new('test', true) }
  let(:controller_class) { Api::TestObjectsController }
  let(:controller) { controller_class.new }
  let(:filter) { AnnounceActions::AnnounceFilter.new('create', {}) }

  before do
    class FooTestObject < TestObject; end

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

  it 'can use an optional subject name' do
    filter.announce_subject(resource).must_equal 'test_object'
    filter.options[:subject] = 'foo'
    filter.announce_subject(resource).must_equal 'foo'
  end

  it 'can get subject name from base class' do
    filter.announce_subject(FooTestObject.new).must_equal 'test_object'
  end

  it 'can use an optional action name' do
    filter.announce_action.must_equal('create')
    filter.options[:action] = 'foo'
    filter.announce_action.must_equal('foo')
  end

  it 'defaults to the msg then min decorator when possible' do
    dc = filter.decorator_class('TestObject')
    dc.must_equal Api::Min::TestObjectRepresenter

    class Api::Msg::TestObjectRepresenter < Api::Min::TestObjectRepresenter; end
    dc = filter.decorator_class('TestObject')
    dc.must_equal Api::Msg::TestObjectRepresenter
    Api::Msg.send(:remove_const, :TestObjectRepresenter)
  end

  it 'gets the decorator to use based on the resource' do
    dc = filter.decorator_for_model(resource)
    dc.must_equal Api::Min::TestObjectRepresenter
  end

  it 'gets the decorator to use based on the resource base class' do
    FooTestObject.base_class.must_equal TestObject
    dc = filter.decorator_for_model(FooTestObject.new('foo', true))
    dc.must_equal Api::Min::TestObjectRepresenter
  end

  it 'can use an optional decorator' do
    filter.options[:decorator] = Api::TestObjectRepresenter
    dc = filter.announce_decorator(resource)
    dc.must_equal Api::TestObjectRepresenter
  end

  it 'tries the action specific resource method' do
    def controller.foo_resource; 'foo'; end
    filter.announce_resource('foo', controller).must_equal 'foo'
  end
end
