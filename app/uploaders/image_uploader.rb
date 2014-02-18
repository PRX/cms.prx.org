# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # :thumbnails => { :square => '75x75', :small=>'120x120', :medium=>'240x240' }
  def self.version_formats
    {
      'square' => {'scale' => [75, 75]},
      'small'  => {'scale' => [120, 120]},
      'medium' => {'scale' => [240, 240]}
    }
  end

  version_formats.keys.each do |label|
    version label do
      process scale: version_formats[label]['scale']
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir    
    "public/#{model.class.to_s.pluralize.underscore}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # From prx.org
  # :thumbnails => { :square => '75x75', :small=>'120x120', :medium=>'240x240' }

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def full_filename(for_file)
    image_filename(for_file)
  end

  def full_original_filename
    image_filename(super)
  end

  def image_filename(for_file, version=version_name)
    return for_file unless version
    ext = File.extname(for_file)
    base = File.basename(for_file, ext)
    "#{base}_#{version}#{ext}"
  end

end
