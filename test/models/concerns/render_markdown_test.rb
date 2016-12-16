# encoding: utf-8

require 'test_helper'
require 'render_markdown'

class TestMarkdownModel
  include RenderMarkdown
end

describe TestMarkdownModel do
  let(:model) { TestMarkdownModel.new }

  it 'converts markdown to html' do
    model.markdown_to_html("_This is markdown_\n\n").must_equal "<p><em>This is markdown</em></p>\n"
  end

  it 'converts html to markdown ' do
    model.html_to_markdown("<p><em>This is markdown</em></p>\n").must_equal "_This is markdown_\n\n"
  end
end
