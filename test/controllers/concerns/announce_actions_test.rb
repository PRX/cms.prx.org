# encoding: utf-8

require 'announce_actions'

Api::TestObjectsController.class_eval do
  include AnnounceActions
  announce_actions(:update, resource: :parent)
  announce_actions(:create, :destroy)
end

Api::TestParentsController.class_eval do
  include AnnounceActions
end

describe Api::TestObjectsController do

  describe 'test callbacks' do
    let (:controller_class) { Api::TestObjectsController }

    before do
      define_routes
      clear_messages
    end

    after do
      Rails.application.reload_routes!
    end

    it 'will call announce' do
      post :create, { title: 'foo' }.to_json

      response.must_be :success?
      last_message['subject'].to_s.must_equal 'test_object'
      last_message['action'].to_s.must_equal 'create'
    end

    it 'renames destroy action to delete' do
      delete :destroy, id: 1

      response.must_be :success?
      last_message['subject'].to_s.must_equal 'test_object'
      last_message['action'].to_s.must_equal 'delete'
    end

    it 'will call announce on a different resource' do
      put :update, id: 1

      response.must_be :success?
      last_message['subject'].to_s.must_equal 'test_parent'
      last_message['action'].to_s.must_equal 'update'
    end
  end

  describe 'test setting announce actions' do
    let (:controller_class) { Api::TestParentsController }

    before do
      controller_class.announced_actions = []
    end

    it 'can declare announced actions' do
      controller_class.announce_actions(:destroy)
      controller_class.announced_actions.size.must_equal 1
    end

    it 'prevents dupe announcements on same resource or subject' do
      controller_class.announce_actions(:destroy)
      controller_class.announce_actions(:destroy, :update)
      controller_class.announced_actions.size.must_equal 2
    end

    it 'allows same action to be announced multiple times with different resource or subject' do
      controller_class.announce_actions(:destroy)
      controller_class.announce_actions(:destroy, subject: 'bar')
      controller_class.announce_actions(:destroy, subject: 'foo')
      controller_class.announced_actions.size.must_equal 3
    end

    it 'defaults to create, update, and destroy' do
      default_actions = [:create, :destroy, :update]
      controller_class.announce_actions
      controller_class.announced_actions.sort.must_equal default_actions
    end
  end
end
