class Image < ActiveRecord::Base
	has_attached_file :image, :styles => { :thumb => "100x100>" } 

  # Validate content type
  validates_attachment_content_type :image, :content_type => /\Aimage/

  # Validate filename
  validates_attachment_file_name :image, :matches => [/png\Z/, /jpe?g\Z/]

	belongs_to :imagable, :polymorphic => true
	belongs_to :user
end
