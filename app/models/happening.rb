class Happening < ActiveRecord::Base
	include PublicActivity::Model
	tracked

  validates :name, :description, :address, :link, :date, :city, :postalCode, :country, presence: true

  has_many :tracks
  
  has_many :user_statuses, :dependent => :destroy

  has_many :users, :through => :user_statuses

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  belongs_to :event_type

	has_many :favorites, :as => :favoritable, dependent: :destroy

	has_many :images, :as => :imagable, dependent: :destroy
end
