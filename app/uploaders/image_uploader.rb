# encoding: utf-8
 
class ImageUploader < CarrierWave::Uploader::Base
 
  # Include RMagick or ImageScience support
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  include CarrierWave::MiniMagick
 
  # Choose what kind of storage to use for this uploader
  # storage :file
  # storage :s3
  # storage :cloud_files
  storage :fog
 
  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end
 
  # Provide a default URL as a default if there hasn't been a file uploaded
  #     def default_url
  #       "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  #     end
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    "/images/no_image_#{version_name}.png"
  end
 
  # Process files as they are uploaded.
  #   process :scale => [200, 300]
  #
  #   def scale(width, height)
  #     # do something
  #   end
 
  # Create different versions of your uploaded files
  process :resize_to_fit => [800, 600]
 
  version :thumb do
    process resize_and_crop: 100
  end
 
  version :medium do
    process resize_to_fit: [700, nil]
  end
 
  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  private

  # Simplest way
  def crop(geometry)
    manipulate! do |img|      
      img.crop(geometry)
      img
    end    
  end

  # Resize and crop square from Center
  def resize_and_crop(size)  
    manipulate! do |image|                 
      if image[:width] < image[:height]
        remove = ((image[:height] - image[:width])/2).round 
        image.shave("0x#{remove}") 
      elsif image[:width] > image[:height] 
        remove = ((image[:width] - image[:height])/2).round
        image.shave("#{remove}x0")
      end
      image.resize("#{size}x#{size}")
      image
    end
  end
end