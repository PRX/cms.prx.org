# encoding: utf-8
require 'elasticsearch/model'

class GroupAccount < Account
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
end
