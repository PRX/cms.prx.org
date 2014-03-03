# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module UriHelper
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

  def prx_model_uri(*args)
    names = args.collect{|arg| prx_model_uri_part_to_string(arg)}.flatten.compact
    "http://meta.prx.org/model/#{names.join("/")}"
  end

  def prx_model_uri_part_to_string(part)
    if part.is_a?(String) || part.is_a?(Symbol)
      part.to_s
    else
      klass = part.is_a?(Class) ? part : (part.try(:item_class) || part.class)
      if klass.respond_to?(:base_class) && (klass.superclass != BaseModel)
        base = klass.superclass.name.underscore
        child = klass.name.underscore.gsub(/_#{base}$/, "")
        [base, child]
      else
        klass.name.underscore
      end
    end
  end

end
