class Api::ApiRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :version

  link :self do
    api_root_path(represented.version)
  end

  links :stories do
    [
      { profile: 'http://meta.prx.org/model/story', href: api_stories_path_template(api_version: represented.version)},
      { profile: 'http://meta.prx.org/model/story', href: api_story_path_template(api_version: represented.version, id: '{id}')}
    ]
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.ends_with?('_path_template')
      original_method_name = method_name[0..-10]
      template_named_path(original_method_name, *args)
    end
  end

  def template_named_path(named_path, options)
    replace_options = options.keys.inject({}){|s,k| s[k] = "#{k.upcase}_REPLACE"; s}
    path = self.send(named_path, replace_options)
    replace_options.keys.each{|k| path.gsub!(replace_options[k], options[k])}
    path
  end

end
