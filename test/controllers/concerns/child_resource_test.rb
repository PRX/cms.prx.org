require 'test_helper'

class Son
  extend ActiveModel::Naming
  attr_accessor :mom, :id

  def destroyed?
    true
  end

  def persisted?
    false
  end

  def to_model
    self
  end

  def to_param
    id
  end

  def self.where(*_args)
    @@singleton ||= new.tap { |s| s.mom = Mom.new }
  end

  def build
    self
  end

  def initialize
    self.id = 1
  end
end

class Mom
  extend ActiveModel::Naming
  attr_accessor :son, :id

  def persisted?
    false
  end

  def to_model
    self
  end

  def to_param
    id
  end

  def self.find_by_id(*_args)
    @@singleton ||= new.tap { |m| m.son = Son.new }
  end

  def initialize
    self.id = 1
  end
end

class Api::SonsController < ActionController::Base
  include HalApi::Controller
  include ChildResource

  child_resource parent: 'mom', child: 'son'

  def authorize(_r)
    true
  end
end

class Api::SonRepresenter < Api::BaseRepresenter
  property :id

  def self_url(represented)
    api_mom_son_path(represented.mom)
  end
end

def define_child_routes
  Rails.application.routes.draw do
    namespace :api do
      resources :moms do
        resource :son
      end
    end
  end
end

describe Api::SonsController do
  before do
    define_child_routes
    @request.env['CONTENT_TYPE'] = 'application/json'
  end

  after { Rails.application.reload_routes! }

  it 'is a child resource' do
    @controller.must_be :child_resource?
  end

  it 'creates a child resource' do
    post :create, mom_id: 1
    response.must_be :success?
  end

  it 'knows the child resource name' do
    @controller.child_resource_name.must_equal 'son'
  end

  it 'knows the parent resource name' do
    @controller.parent_resource_name.must_equal 'mom'
  end

  it 'gets the parent' do
    mom = Mom.find_by_id(1)
    mom.wont_be_nil
    @controller.params = { mom_id: 1 }
    @controller.parent_resource.must_equal mom
  end

  it 'retrieves the child resource' do
    mom = Mom.find_by_id(1)
    mom.wont_be_nil
    son = mom.son
    son.wont_be_nil
    @controller.params = { mom_id: 1 }
    @controller.child_resource.must_equal mom.son
  end

  it 'raises not found for missing child resource' do
    mom = Mom.find_by_id(1)
    mom.stub(:son, nil) do
      -> { @controller.child_resource }.must_raise HalApi::Errors::NotFound
    end
  end

  it 'raises not found for missing parent resource' do
    Mom.stub(:find_by_id, nil) do
      -> { @controller.parent_resource }.must_raise HalApi::Errors::NotFound
      -> { @controller.child_resource }.must_raise HalApi::Errors::NotFound
    end
  end
end
