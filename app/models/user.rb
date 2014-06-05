class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:facebook]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_messageable
  validates :username, uniqueness: true
  
  mount_uploader :avatar, ImageUploader, :delayed=> true 

  has_many :user_statuses, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :happenings, :through => :user_statuses, :dependent  => :destroy
  has_many :happenings_as_owner, :class_name => "Happening", :dependent  => :destroy
  has_many :tracks, :dependent  => :destroy

  has_many :groupers, :conditions => 'accepted_on IS NOT NULL', :dependent => :destroy
  has_many :groups, :through => :groupers
  has_many :groups_as_owner, :class_name => "Group"

  # has_many :conversation, :dependent => :destroy
  # has_many :messages, :through => :conversation
  # has_many :messages_as_owner, :class_name => "Message"

  has_many :forums, :dependent => :destroy
  has_many :announces, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  belongs_to :role

  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.username = auth.info.first_name+' '+auth.info.last_name
      user.firstname = auth.info.first_name
      user.lastname = auth.info.last_name
      user.description = auth.info.about
      if auth.info.image.present?
         avatar_url = process_uri(auth.info.image)
         user.update_attribute(:avatar, URI.parse(avatar_url))
      end
    end
  end

  def self.search(search)
    query_obj = all
    query_obj = query_obj.where("username LIKE ?", "%#{search}%")
  end

  def to_param
    username
  end

  private
    def self.process_uri(uri)
      require 'open-uri'
      require 'open_uri_redirections'
      open(uri, :allow_redirections => :safe) do |r|
        r.base_uri.to_s
      end
    end
end
