# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register 'application/hal+json', :hal

# roar fix for 4.1
# https://github.com/apotonick/roar-rails/issues/65
ActionController.add_renderer :hal do |js, options|
  self.content_type ||= Mime::HAL
  js.to_json
end
