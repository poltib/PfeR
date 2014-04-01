class Happening < ActiveRecord::Base
	include PublicActivity::Model
	tracked

	mount_uploader :route, RouteUploader
	mount_uploader :routegpx, RouteUploader
	mount_uploader :routekml, RouteUploader
	mount_uploader :routetcx, RouteUploader

  validates :name, :description, :address, :link, :date, :city, :postalCode, :country, presence: true

  has_many :user_statuses

  has_many :users, :through => :user_statuses

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  belongs_to :event_type
end
