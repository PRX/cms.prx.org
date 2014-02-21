# encoding: utf-8

class AudioFileUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Create different versions of your uploaded files:
  def self.version_formats
    {
      'broadcast' => {'format' => 'mp3', 'bit_rate' => 128, 'sample_rate' => 44100},
      'download'  => {'format' => 'mp3', 'bit_rate' => 64,  'sample_rate' => 44100},
      'preview'   => {'format' => 'mp3', 'bit_rate' => 64,  'sample_rate' => 44100, 'cut' => {'length' => 30}}
    }
  end

  version_formats.keys.each do |label|
    version label
  end

  def store_dir
    "public/#{model.class.to_s.pluralize.underscore}/#{model.id}"
  end

  def extension_white_list
    ['aac', 'aif', 'aiff', 'alac', 'flac', 'm4a', 'm4p', 'mp2', 'mp3', 'mp4', 'ogg', 'raw', 'spx', 'wav', 'wma']
  end

  def full_filename(for_file)
    audio_file_version_filename(for_file)
  end

  def full_original_filename
    audio_file_version_filename(super)
  end

  def audio_file_version_filename(for_file, version=version_name)
    return for_file unless version
    base = File.basename(for_file, File.extname(for_file))
    "#{base}_#{version}.#{version_ext(version)}"
  end

  def version_ext(version)
    AudioFileUploader.version_formats[version.to_s]['format']
  end

end
