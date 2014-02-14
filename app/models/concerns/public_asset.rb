require 'active_support/concern'
require 'digest/md5'

# expects underlying model to have filename, class, and id attributes
module PublicAsset
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  # validates token with or without expires option
  def public_url_token(options={})
    o = set_asset_option_defaults(options)

    t = token_secret
    e = o[:expires]
    u = o[:use]
    c = o[:class]
    i = o[:id]
    v = o[:version]
    n = o[:name]
    x = o[:extension]

    str = [t,e,u,c,i,v,n,x].join("|")

    Digest::MD5.hexdigest(str)
  end

  # media/:token/:expires/:use/:class/:id/:name.:extension
  def public_url(options={})
    o = set_asset_option_defaults(options)

    t = public_url_token(o)
    e = o[:expires]
    u = o[:use]
    c = o[:class]
    i = o[:id]
    v = o[:version]
    n = o[:name]
    x = o[:extension]

    url = root_url + ["pub",t,e,u,c,i,v,n].join("/")
    url = url + ".#{x}" unless x.blank?
    url
  end

  def asset_url(options={})
    # v = options[:version]
    # v = nil if (v.blank? || v.to_s == 'original')
    # file.try(:url, *v)
    raise NotImplementedError.new("You must implement asset_url.")
  end

  def public_asset_filename
    # File.basename(file.path)
    raise NotImplementedError.new("You must implement public_asset_filename.")
  end

  def public_url_valid?(options={})
    token_valid?(options) && !url_expired?(options)
  end

  def url_expired?(options)
    expires = options[:expires].to_i
    now     = DateTime.now.to_i
    return ((expires == 0) || (expires > now))
  end    

  def token_valid?(options)
    token   = options[:token]
    check   = public_url_token(options)
    return (token == check)
  end

  def set_asset_option_defaults(options={})
    o = HashWithIndifferentAccess.new({
      use:       'web',
      class:     self.class.name.demodulize.underscore,
      id:        id,
      version:   'original',
      name:      filename_base,
      extension: filename_extension
    }).merge(options)
    o[:expires] = o[:expires].to_i
    o
  end

  def filename_base
    fn = public_asset_filename || 'asset'
    File.basename(fn, File.extname(fn))
  end

  def filename_extension
    fn = public_asset_filename || ''
    ext = File.extname(fn)
    (!ext.blank? && (ext.first == '.')) ? ext[1..-1] : ''
  end

  def token_secret
    ENV['PUBLIC_ASSET_SECRET']
  end

end
