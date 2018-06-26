# encoding: utf-8
require 'elasticsearch/model'

class StationAccount < Account
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
end
