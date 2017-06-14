# encoding: utf-8

require 'active_support/concern'
require 'redcarpet'
require 'reverse_markdown'

module RenderMarkdown
  extend ActiveSupport::Concern

  def html_to_markdown(str)
    return nil unless str
    ReverseMarkdown.convert(str).strip
  end

  def markdown_to_html(str)
    return nil unless str
    md = Redcarpet::Markdown.new(markdown_html_renderer, markdown_extensions)
    str = md.render(str || '').strip
    convert_escaped_newlines(str)
  end

  def convert_escaped_newlines(str)
    str.gsub(/\\<br>/, '<br>')
  end

  def markdown_extensions
    {
      tables: true,
      autolink: true
    }
  end

  def markdown_html_renderer
    options = {
      filter_html: false,
      no_styles: true,
      safe_links_only: true,
      hard_wrap: true,
      with_toc_data: true,
      link_attributes: { rel: 'nofollow', target: '_blank' },
    }
    Redcarpet::Render::HTML.new(options)
  end
end
