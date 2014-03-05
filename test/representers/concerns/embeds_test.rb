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
  let(:test_object) { TestObject.new("test", true) }
  let(:mapper) { 
    m = TestEmbedsMapper.new
    m.represented = test_object
    m
  }

  let(:binding) { Struct.new(:options).new({}) }

  it "when embedded false, don't skip it" do
    binding.options = {as: 't:test', embedded: false}
    mapper.suppress_embed?(binding, {}).must_equal false
  end

  it "when embed true, skip if zoom not indicated" do
    binding.options = {as: 't:test', embedded: true}
    mapper.suppress_embed?(binding, {}).must_equal true

    binding.options[:zoom] = false
    mapper.suppress_embed?(binding, {zoom_param: ['prx:none']}).must_equal true
  end

  it "when embed true, and zoom true, and root true, don't skip" do
    binding.options = {as: 't:test', embedded: true}
    mapper.suppress_embed?(binding, {zoom_param: ['t:test']}).must_equal false
  end

  it "when embed true, and zoom true, and root false, skip!" do
    binding.options = {as: 't:test', embedded: true}
    mapper.represented.is_root_resource = false
    mapper.suppress_embed?(binding, {zoom_param: ['t:test']}).must_equal true

    binding.options[:zoom] = true
    mapper.suppress_embed?(binding, {}).must_equal true
  end

  it "when zoom :always, do not skip" do
    binding.options = {as: 't:test', embedded: true, zoom: :always}
    mapper.suppress_embed?(binding, {}).must_equal false

    mapper.represented.is_root_resource = true
    mapper.suppress_embed?(binding, {}).must_equal false
  end

  it "defines an embed to set a representable property" do

    class Embeds1TestRepresenter < Api::BaseRepresenter
      embed :test_object, class: TestObject, zoom: :always
    end

    embed_definition = Embeds1TestRepresenter.representable_attrs[:test_object]
    embed_definition.wont_be_nil
    embed_definition.options[:embedded].must_equal true
    embed_definition.options[:class].must_equal TestObject
    embed_definition.options[:zoom].must_equal :always
  end

  it "defines an embed to set a representable property" do

    class Embeds2TestRepresenter < Api::BaseRepresenter
      embeds :test_objects, class: TestObject, zoom: :always
    end

    embed_definition = Embeds2TestRepresenter.representable_attrs[:test_objects]
    embed_definition.wont_be_nil
    embed_definition.options[:embedded].must_equal true
    embed_definition.options[:class].must_equal TestObject
    embed_definition.options[:zoom].must_equal :always
  end

end
