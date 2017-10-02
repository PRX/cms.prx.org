# encoding: utf-8
require 'active_support/concern'

# an uploaded file is moved from temp location to final dest via fixer
module Fixerable
  extend ActiveSupport::Concern

  class_methods do
    def fixerable_upload(temp_field, final_field)
      @fixerable_temp_field = temp_field
      @fixerable_final_field = final_field

      # alias filename field until upload has completed
      mask_field = final_field
      if try(:uploader_options) && uploader_options[final_field] && uploader_options[final_field][:mount_on]
        mask_field = uploader_options[final_field][:mount_on]
      end
      define_method mask_field do
        if fixerable_final?
          read_attribute(mask_field)
        else
          public_asset_filename
        end
      end
    end

    def fixtemp
      @fixerable_temp_field || superclass.try(:fixtemp)
    end

    def fixfinal
      @fixerable_final_field || superclass.try(:fixfinal)
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
      expiration = fixerable_url_expires_at(uploader, options)

      if provider === credentials[:provider]
        if provider === 'AWS' && options.delete(:head)
          connection.head_object_url(bucket, path, expiration, options)
        else
          # avoid a get by using local references
          local_directory = connection.directories.new(key: bucket)
          local_file = local_directory.files.new(key: path)
          local_file.url(expiration, options)
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
    if fixerable_final?
      File.basename(fixfinal.path)
    else
      File.basename(URI.parse(fixtemp || '').path)
    end
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
    if options.delete(:head) && f.respond_to?(:authenticated_head_url)
      f.authenticated_head_url
    else
      f.url
    end
  end

  def fixerable_final_storage_url
    return unless fixerable_final?
    scheme = self.class.fixerable_storage.invert[fixfinal.fog_credentials[:provider]]
    options = {
      scheme: scheme,
      host: fixfinal.fog_directory,
      path: "/#{fixfinal.path}",
    }
    URI::Generic.build(options).to_s
  end

  def fixerable_final_path
    fixfinal.store_dir
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
