require 'test_helper'

class Mammal
  extend ActiveModel::Naming
  attr_accessor :id, :type

  def becomes(klass)
    klass.new
  end

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
    @@singleton ||= new
  end

  def find(*_args)
    @@singleton ||= new
  end

  def build
    self
  end

  def id
    1
  end

  def save!; end
end

class Dog < Mammal
  attr_accessor :woof

  def type
    'Dog'
  end

  def id
    1
  end
end

class Api::MammalsController < ActionController::Base
  include HalApi::Controller
  include AbstractResource

  def authorize(_r)
    true
  end
end

class Api::MammalRepresenter < Api::BaseRepresenter
  property :id
  property :type

  def self_url(represented)
    polymorphic_path([:api, represented.becomes(Mammal)])
  end
end

class Api::DogRepresenter < Api::MammalRepresenter
  property :woof
end

def define_test_routes
  Rails.application.routes.draw do
    namespace :api do
      resources :mammals
    end
  end
end

describe Api::MammalsController do
  before do
    define_test_routes
    @request.env['CONTENT_TYPE'] = 'application/json'
  end

  after { Rails.application.reload_routes! }

  it 'creates and returns the resource based on type' do
    post :create, { type: 'Dog' }.to_json, format: 'json'
    response.must_be :success?
    dog = JSON.parse(response.body)
    dog['type'].must_equal 'Dog'
  end
end
