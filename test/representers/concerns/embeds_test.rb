# encoding: utf-8

require 'test_helper'
require 'test_models'

class TestEmbedsMapper

  attr_accessor :represented

  include Embeds::Resources

end

EmbedsTest = Struct.new(:title)

describe Embeds do

  let(:helper) { class TestUriMethods; include Embeds; end.new }
  let(:t_object) { TestObject.new("test", true) }
  let(:mapper) {
    m = TestEmbedsMapper.new
    m.represented = t_object
    m
  }

  let(:binding) { Struct.new(:as, :embedded, :zoom).new('t:test', true, nil) }

  describe "non embedded property" do
    let (:non_embed_binding) { binding.tap{|b| b.embedded = false } }

    it "is never suppressed" do
      mapper.suppress_embed?(non_embed_binding, {}).must_equal false
    end
  end

  describe "default zoom" do
    let (:default_binding) { binding.tap{|b| b.zoom = nil } }

    it "is not suppressed by default" do
      mapper.suppress_embed?(default_binding, {}).must_equal false
    end

    it "is suppressed when specifically unrequested" do
      mapper.suppress_embed?(default_binding, {zoom: ['t:none']}).must_equal true
    end
  end

  describe "zoom: true" do
    let (:true_binding) { binding.tap{|b| b.zoom = true } }

    it "is not suppressed by default" do
      mapper.suppress_embed?(true_binding, {}).must_equal false
    end

    it "is suppressed when specifically unrequested" do
      mapper.suppress_embed?(true_binding, {zoom: ['t:none']}).must_equal true
    end

    it "is unsuppressed when requested" do
      mapper.suppress_embed?(true_binding, {zoom: ['t:test']}).must_equal false
    end
  end

  describe "zoom: always" do
    let (:always_binding) { binding.tap{|b| b.zoom = :always } }

    it "is not suppressed when specifically unrequested" do
      mapper.suppress_embed?(always_binding, {zoom: ['t:test']}).must_equal false
    end
  end

  describe "zoom: false" do
    let (:false_binding) { binding.tap{|b| b.zoom = false } }

    it "is suppressed by default" do
      mapper.suppress_embed?(false_binding, {}).must_equal true
    end
  end

  it "defines an embed to set a representable property" do

    class Embeds1TestRepresenter < Api::BaseRepresenter
      embed :test_object, class: TestObject, zoom: :always
    end

    embed_definition = Embeds1TestRepresenter.representable_attrs[:test_object]
    embed_definition.wont_be_nil
    embed_definition[:embedded].must_equal true
    embed_definition[:class].evaluate(nil).must_equal TestObject
    embed_definition[:zoom].must_equal :always
  end

  it "defines an embed to set a representable property" do

    class Embeds2TestRepresenter < Api::BaseRepresenter
      embeds :test_objects, class: TestObject, zoom: :always
    end

    embed_definition = Embeds2TestRepresenter.representable_attrs[:test_objects]
    embed_definition.wont_be_nil
    embed_definition[:embedded].must_equal true
    embed_definition[:class].evaluate(nil).must_equal TestObject
    embed_definition[:zoom].must_equal :always
  end

end
