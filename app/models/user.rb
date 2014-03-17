class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  # validates :username, presence: true, length: {maximum: 255}, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]*\z/, message: "may only contain letters and numbers." }


  has_many :user_statuses
  has_many :happenings, :through => :user_status
  has_many :happenings_as_owner, :class_name => "Happening"

  has_many :groupers
  has_many :groups, :through => :grouper
  has_many :groups_as_owner, :class_name => "Group"

  has_many :teamers
  has_many :teams, :through => :teamer
  has_many :teams_as_owner, :class_name => "Team"

  has_many :conversations
  has_many :messages, :through => :conversation
  has_many :messages_as_owner, :class_name => "Message"

  has_many :forums
  has_many :announces
  belongs_to :role
end
