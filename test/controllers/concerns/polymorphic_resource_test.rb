require 'test_helper'

class FoosController < ActionController::Base
  include PolymorphicResource

  def self.resources_params
    ["bar_id"]
  end

  def params
    ActionController::Parameters.new( { "bar_id" => 100, "whatever" => "abc" } )
  end
end

describe PolymorphicResource do
  it 'adds polymorphic conditions to the query' do
    arel = Arel::Table.new(:foos)
    result = FoosController.new.polymorphic_filtered("barable", arel)
    result.constraints.must_equal [ { "barable_id" => 100, "barable_type" => "Bar" } ]
  end
end
