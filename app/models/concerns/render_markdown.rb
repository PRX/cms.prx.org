# encoding: utf-8

require 'active_support/concern'
require 'redcarpet'
require 'reverse_markdown'

module RenderMarkdown
  extend ActiveSupport::Concern

  def html_to_markdown(str)
    ReverseMarkdown.convert(str)
  end

  def markdown_to_html(str = '')
    md = Redcarpet::Markdown.new(markdown_html_renderer, markdown_extensions)
    md.render(str || '')
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
