# encoding: utf-8

require 'announce_actions'

describe Api::TestObjectsController do

  let (:controller_class) { Api::TestObjectsController }

  before do
    controller_class.class_eval { include AnnounceActions }
    controller_class.announced_actions = []
    clear_messages
  end

  it 'can declare announced actions' do
    controller_class.announce_actions(:destroy)
    controller_class.announced_actions.size.must_equal 1
  end

  it 'prevents dupe announcements' do
    controller_class.announce_actions(:destroy)
    controller_class.announce_actions(:destroy, :update)
    controller_class.announced_actions.size.must_equal 2
  end

  it 'defaults to create, update, and destroy' do
    default_actions = [:create, :destroy, :update]
    controller_class.announce_actions
    controller_class.announced_actions.sort.must_equal default_actions
  end

  describe 'test callbacks' do

    before { define_routes }
    after { Rails.application.reload_routes! }

    it 'will call announce' do
      controller_class.announce_actions(:create)

      post :create, { title: 'foo' }.to_json

      response.must_be :success?
      last_message['subject'].to_s.must_equal 'test_object'
      last_message['action'].to_s.must_equal 'create'
    end

    it 'renames destroy action to delete' do
      controller_class.announce_actions(:destroy)

      delete :destroy, id: 1

      response.must_be :success?
      last_message['subject'].to_s.must_equal 'test_object'
      last_message['action'].to_s.must_equal 'delete'
    end
  end
end
