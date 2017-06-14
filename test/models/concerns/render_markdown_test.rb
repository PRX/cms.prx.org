# encoding: utf-8

require 'test_helper'
require 'render_markdown'

class TestMarkdownModel
  include RenderMarkdown
end

describe TestMarkdownModel do
  let(:model) { TestMarkdownModel.new }

  it 'converts markdown to html' do
    model.markdown_to_html("_This is markdown_\n").must_equal "<p><em>This is markdown</em></p>"
  end

  it 'converts html to markdown ' do
    model.html_to_markdown("\n<p><em>This is markdown</em></p>\n").must_equal "_This is markdown_"
  end

  it 'converts escaped new lines without slashes' do
    model.markdown_to_html("one\n\n\\\nanother\n").must_equal "<p>one</p>\n\n<p><br>\nanother</p>"
    model.markdown_to_html("one\n\\\n\\\n\\\nanother\n").must_equal "<p>one<br>\n<br>\n<br>\n<br>\nanother</p>"
    model.markdown_to_html("one\n\\\n\\\nanother\n").must_equal "<p>one<br>\n<br>\n<br>\nanother</p>"
  end
end
