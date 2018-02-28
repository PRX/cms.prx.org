# encoding: utf-8

require 'test_helper'
require 'render_markdown'

class TestMarkdownModel
  include RenderMarkdown
end

describe TestMarkdownModel do
  let(:model) { TestMarkdownModel.new }

  it 'converts markdown to html' do
    model.markdown_to_html("_This is markdown_\n").must_equal '<p><em>This is markdown</em></p>'
  end

  it 'converts html to markdown ' do
    model.html_to_markdown("\n<p><em>This is markdown</em></p>\n").must_equal '_This is markdown_'
  end

  it 'converts escaped new lines without slashes' do
    model.markdown_to_html("o\n\n\\\na\n").must_equal "<p>o</p>\n\n<p><br>\na</p>"
    model.markdown_to_html("o\n\\\n\\\n\\\na\n").must_equal "<p>o<br>\n<br>\n<br>\n<br>\na</p>"
    model.markdown_to_html("o\n\\\n\\\na\n").must_equal "<p>o<br>\n<br>\n<br>\na</p>"
  end
end
