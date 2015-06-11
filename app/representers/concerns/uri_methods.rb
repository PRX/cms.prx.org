# encoding: utf-8

require 'active_support/concern'

# expects underlying model to have filename, class, and id attributes
module UriMethods
  extend ActiveSupport::Concern

  module ClassMethods
    def self_link
      link(:self) do
        {
          href: self_url(represented),
          profile: profile_url(represented)
        }
      end
    end

    def profile_link
      link(:profile) { profile_url(represented) }
    end

    def alternate_link
      link :alternate do
        {
          href: prx_web_url(prx_model_web_path(represented)),
          type: 'text/html'
        }
      end
    end

    def prx_meta_host
      (ENV['META_HOST'] || 'meta.prx.org')
    end
  end

  def prx_model_web_path(represented)
    rep = becomes_represented_class(represented)
    class_path = rep.class.name.underscore.pluralize
    "#{class_path}/#{represented.id}"
  end

  def self_url(represented)
    rep = becomes_represented_class(represented)
    polymorphic_path([:api, rep])
  end

  def profile_url(represented)
    prx_model_uri(represented)
  end

  def becomes_represented_class(rep)
    return rep unless rep.respond_to?(:becomes)
    klass = rep.try(:item_class) || rep.class.try(:base_class)
    (klass && (klass != rep.class)) ? rep.becomes(klass) : rep
  end

  def prx_web_url(*path)
    path = path.map(&:to_s).join('/')
    "https://#{prx_web_host}/#{path}"
  end

  def prx_model_uri(*args)
    "http://#{prx_meta_host}/model/#{joined_names(args)}"
  end

  def prx_meta_host
    (ENV['META_HOST'] || 'meta.prx.org')
  end

  def prx_web_host
    (ENV['PRX_HOST'] || 'www.prx.org')
  end

  def joined_names(args)
    (Array(args.map { |arg| prx_model_uri_part_to_string(arg) }) +
      prx_model_uri_suffix(args)).flatten.compact.join('/')
  end

  def prx_model_uri_suffix(args)
    represented = args.last
    klass = represented.try(:item_decorator) || self.class
    klass.name.deconstantize.underscore.dasherize.split('/')[1..-1] || []
  end

  def prx_model_uri_part_to_string(part)
    if part.is_a?(String) || part.is_a?(Symbol)
      part.to_s.dasherize
    else
      klass = part.is_a?(Class) ? part : (part.try(:item_class) || part.class)
      if klass.respond_to?(:base_class) && (klass.superclass != BaseModel)
        base = klass.superclass.name.underscore.dasherize
        child = klass.name.underscore.gsub(/_#{base}$/, "").dasherize
        [base, child]
      else
        klass.name.underscore.dasherize
      end
    end
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.ends_with?('_path_template')
      original_method_name = method_name[0..-10]
      template_named_path(original_method_name, *args)
    else
      super(method_name, *args, &block)
    end
  end

  def template_named_path(named_path, options)
    replace_options = options.keys.inject({}) do |s, k|
      s[k] = "_#{k.upcase}_REPLACE_"
      s
    end
    path = send(named_path, replace_options)
    replace_options.keys.each do |k|
      path.gsub!(replace_options[k], (options[k] || ''))
    end
    path
  end
end
