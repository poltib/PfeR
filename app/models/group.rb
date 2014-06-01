class Group < ActiveRecord::Base
	mount_uploader :avatar, ImageUploader, :delayed=> true 

  validates :name, :description, :avatar, presence: true
  validates :name, uniqueness: true

  has_many :groupers, :conditions => 'accepted_on IS NOT NULL', :dependent => :destroy

  has_many :users, :through => :groupers

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  has_many :happenings
  has_many :tracks

end
