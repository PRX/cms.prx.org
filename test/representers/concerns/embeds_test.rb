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

  it "when embedded false, don't skip it" do
    binding.embedded = false
    mapper.suppress_embed?(binding, {}).must_equal false
  end

  it "when embed true, skip if zoom not indicated" do
    mapper.suppress_embed?(binding, {}).must_equal true

    binding.zoom = false
    mapper.suppress_embed?(binding, {zoom: ['prx:none']}).must_equal true
  end

  it "when embed true, and zoom true, and root true, don't skip" do
    mapper.suppress_embed?(binding, {zoom: ['t:test']}).must_equal false
  end

  it "when embed true, and zoom true, and root false, don't skip!" do
    mapper.represented.is_root_resource = false
    mapper.suppress_embed?(binding, {zoom: ['t:none']}).must_equal true
    mapper.suppress_embed?(binding, {zoom: ['t:test']}).must_equal false

    mapper.suppress_embed?(binding, {}).must_equal true
    binding.zoom = true
    mapper.suppress_embed?(binding, {}).must_equal false
  end

  it "when zoom :always, do not skip" do
    binding.zoom = :always
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
