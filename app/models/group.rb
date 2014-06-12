class Group < ActiveRecord::Base
	mount_uploader :avatar, ImageUploader, :delayed=> true
  geocoded_by :address  
  after_validation :geocode

  validates :name, :description, :address, :avatar, presence: true
  validates :name, uniqueness: true

  has_many :groupers, :conditions => 'accepted_on IS NOT NULL', :dependent => :destroy

  has_many :users, :through => :groupers

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  has_many :happenings
  has_many :tracks

  def self.search(search, address)
    query_obj = all
    query_obj = query_obj.where("name LIKE ?", "%#{search}%")
    query_obj = query_obj.near(address, 20, :units => :km)
  end
end
