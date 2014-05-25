class Group < ActiveRecord::Base
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"

  # Validate content type
  validates_attachment_content_type :avatar, :content_type => /\Aimage/

  # Validate filename
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/]

  # Explicitly do not validate
  do_not_validate_attachment_file_type :avatar

  validates :name, :description, :avatar, presence: true
  validates :name, uniqueness: true

  has_many :groupers, :conditions => 'accepted_on IS NOT NULL', :dependent => :destroy

  has_many :users, :through => :groupers

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  has_many :happenings
  has_many :tracks

end
