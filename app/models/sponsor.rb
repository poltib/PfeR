class Sponsor < ActiveRecord::Base
	mount_uploader :image, ImageUploader, :delayed=> true

  belongs_to :happening
end
