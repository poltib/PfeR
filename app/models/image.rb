class Image < ActiveRecord::Base
	mount_uploader :image, ImageUploader, :delayed=> true 
	
	belongs_to :imagable, :polymorphic => true
	belongs_to :user
end
