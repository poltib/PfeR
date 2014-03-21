class Team < ActiveRecord::Base
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  # Validate content type
  validates_attachment_content_type :avatar, :content_type => /\Aimage/

  # Validate filename
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/]

  # Explicitly do not validate
  do_not_validate_attachment_file_type :avatar
  
  has_many :teamers
  has_many :users, :through => :teamers
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
end
