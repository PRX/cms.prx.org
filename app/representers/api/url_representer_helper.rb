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

  def prx_model_uri(obj)
    name = if obj.is_a?(String) || obj.is_a?(Symbol)
      obj
    else
      klass = obj.is_a?(Class) ? obj : obj.class
      if klass.respond_to?(:base_class) && (klass.base_class != klass)
        base = klass.base_class.name.underscore
        child = klass.name.underscore.gsub(/_#{base}$/, "")
        "#{base}/#{child}"
      else
        klass.name.underscore
      end
    end

    "http://meta.prx.org/model/#{name}"
  end

end