# encoding: utf-8

class AudioFile < BaseModel

  include PublicAsset

  UPLOADED         = 'uploaded'
  VALIDATING       = 'validating'
  VALID            = 'valid'
  INVALID          = 'invalid'
  COMPLETE         = 'complete'
  TRANSFORMING     = 'creating mp3s'
  TRANSFORM_FAILED = 'creating mp3s failed'
  TRANSFORMED      = 'mp3s created'

  belongs_to :account

  belongs_to :audio_version
  has_one :story, through: :audio_version

  acts_as_list scope: :audio_version
  acts_as_paranoid

  alias_attribute :upload, :upload_path
  alias_attribute :duration, :length

  mount_uploader :file, AudioFileUploader, mount_on: :filename

  before_validation do
    if upload
      self.status ||= UPLOADED
    end

    if !account && story
      self.account = story.account
    end
  end

  # `upload` can be any of the protocols of url used by fixer
  # http(s), ftp, s3, ia...
  def asset_url(options = {})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    final_location? ? file.try(:url, *v) : upload_url
  end

  def upload_url
    uri = URI.parse(upload)
    if uri.scheme.starts_with?('http')
      upload
    elsif uri.scheme.starts_with?('ftp')
      nil
    elsif AudioFile.storage_providers[uri.scheme.to_s]
      signed_url(upload)
    end
  end

  def self.storage_providers
    {
      's3'        => 'AWS',
      'ia'        => 'InternetArchive',
      'google'    => 'Google',
      'rackspace' => 'Rackspace',
      'openstack' => 'OpenStack'
    }
  end

  def self.storage_provider_for_uri(uri)
    uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
    storage_providers[uri.scheme]
  end

  def signed_url(uri = upload, options = {})
    return if upload.blank?

    uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
    bucket = uri.host
    path = uri.path[1..-1]
    provider = AudioFile.storage_provider_for_uri(uri)

    credentials = AudioFileUploader.fog_credentials
    connection = Fog::Storage.new(credentials)

    if provider == credentials[:provider]
      # avoid a get by using local references
      local_directory = connection.directories.new(key: bucket)
      local_file = local_directory.files.new(key: path)
      if credentials[:provider] == 'AWS'
        local_file.url(url_expires_at(options), options)
      elsif ['Rackspace', 'OpenStack'].include?(credentials[:provider])
        connection.get_object_https_url(bucket, path, url_expires_at(options))
      else
        local_file.url(url_expires_at(options))
      end
    else
      nil
    end
  end

  def url_expires_at(options)
    ::Fog::Time.now + (options.delete(:expiration) ||
    AudioFileUploader.fog_authenticated_url_expiration)
  end

  def public_asset_filename
    filename
  end

  def filename
    f = self[:filename] || URI.parse(upload || '').path
    File.basename(f) if f
  end

  def final_location?
    [VALID, COMPLETE, TRANSFORMING, TRANSFORM_FAILED, TRANSFORMED].include? status
  end

  def self.policy_class
    AudioFilePolicy
  end
end
