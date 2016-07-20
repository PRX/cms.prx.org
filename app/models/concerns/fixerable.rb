# encoding: utf-8
require 'active_support/concern'

# an uploaded file is moved from temp location to final dest via fixer
module Fixerable
  extend ActiveSupport::Concern

  class_methods do
    def fixerable_upload(temp_field, final_field)
      @fixerable_temp_field = temp_field
      @fixerable_final_field = final_field
    end

    def fixtemp
      @fixerable_temp_field
    end

    def fixfinal
      @fixerable_final_field
    end

    def fixerable_storage
      {
        's3'        => 'AWS',
        'ia'        => 'InternetArchive',
        'google'    => 'Google',
        'rackspace' => 'Rackspace',
        'openstack' => 'OpenStack'
      }
    end

    def fixerable_storage_for_uri(uri)
      uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
      fixerable_storage[uri.scheme]
    end

    def fixerable_signed_url(uri, uploader, options = {})
      return if uri.blank?

      uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
      bucket = uri.host
      path = uri.path[1..-1]
      provider = fixerable_storage_for_uri(uri)

      credentials = uploader.fog_credentials
      connection = Fog::Storage.new(credentials)

      if provider == credentials[:provider]
        # avoid a get by using local references
        local_directory = connection.directories.new(key: bucket)
        local_file = local_directory.files.new(key: path)
        if credentials[:provider] == 'AWS'
          local_file.url(fixerable_url_expires_at(uploader, options), options)
        elsif ['Rackspace', 'OpenStack'].include?(credentials[:provider])
          connection.get_object_https_url(bucket, path, fixerable_url_expires_at(uploader, options))
        else
          local_file.url(fixerable_url_expires_at(uploader, options))
        end
      end
    end

    def fixerable_url_expires_at(uploader, options)
      ::Fog::Time.now + (options.delete(:expiration) ||
      uploader.fog_authenticated_url_expiration).to_i
    end
  end

  def fixtemp
    send(self.class.fixtemp)
  end

  def fixfinal
    send(self.class.fixfinal)
  end

  # override public asset url
  def asset_url(options = {})
    fixerable_final? ? fixerable_final_url(options) : fixerable_temp_url(options)
  end

  # override public asset filename
  def public_asset_filename
    f = fixfinal.path || URI.parse(fixtemp || '').path
    File.basename(f) if f
  end

  # has upload been copied to final destination?
  def fixerable_final?
    true
  end

  # finally!
  def fixerable_final_url(options)
    f = fixfinal
    if f.class.version_formats.keys.include?(options[:version].to_s)
      f = f.try(options[:version])
    end
    if options.key?(:expiration) && options[:expiration].to_i > 0
      f.fog_authenticated_url_expiration = options[:expiration].to_i
    end
    f.url
  end

  # temporary location
  def fixerable_temp_url(options = {})
    uri = URI.parse(fixtemp)
    if uri.scheme.starts_with?('http')
      fixtemp
    elsif uri.scheme.starts_with?('ftp')
      nil
    elsif self.class.fixerable_storage[uri.scheme.to_s]
      self.class.fixerable_signed_url(fixtemp, fixfinal.class, options)
    end
  end
end
