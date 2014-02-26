# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module Api::UrlRepresenterHelper
  extend ActiveSupport::Concern

  def method_missing(method_name, *args, &block)
    if method_name.to_s.ends_with?('_path_template')
      original_method_name = method_name[0..-10]
      template_named_path(original_method_name, *args)
    end
  end

  def template_named_path(named_path, options)
    replace_options = options.keys.inject({}){|s,k| s[k] = "_#{k.upcase}_REPLACE_"; s}
    path = self.send(named_path, replace_options)
    replace_options.keys.each{|k| path.gsub!(replace_options[k], (options[k] || ''))}
    path
  end

  def model_profile_uri(obj)
    klass = obj.is_a?(Class) ? obj : obj.class
    name = klass.name.underscore || ""
    "http://meta.prx.org/model/#{name}"
  end

end