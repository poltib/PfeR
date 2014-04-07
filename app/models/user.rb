class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_messageable
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  # Validate content type
  validates_attachment_content_type :avatar, :content_type => /\Aimage/

  # Validate filename
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/]

  # Explicitly do not validate
  do_not_validate_attachment_file_type :avatar


  has_many :user_statuses, :dependent => :destroy
  has_many :happenings, :through => :user_statuses
  has_many :happenings_as_owner, :class_name => "Happening"

  has_many :grouper, :dependent => :destroy
  has_many :groups, :through => :grouper
  has_many :groups_as_owner, :class_name => "Group"

  has_many :teamer, :dependent => :destroy
  has_many :teams, :through => :teamer
  has_many :teams_as_owner, :class_name => "Team"

  # has_many :conversation, :dependent => :destroy
  # has_many :messages, :through => :conversation
  # has_many :messages_as_owner, :class_name => "Message"

  has_many :forums
  has_many :tracks
  has_many :announces
  has_many :comments
  belongs_to :role
end
