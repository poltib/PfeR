class Happening < ActiveRecord::Base
  include PublicActivity::Model
  tracked
  geocoded_by :address  
  after_validation :geocode, :if => :address_changed? 

  validates :name, :description, :address, :link, :date, presence: true

  has_many :tracks
  
  has_many :user_statuses, :dependent => :destroy

  has_many :users, :through => :user_statuses

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  belongs_to :event_type

  has_many :favorites, :as => :favoritable, dependent: :destroy

  has_many :images, :as => :imagable, dependent: :destroy

  has_many :forums, :as => :forumable, dependent: :destroy

  def self.search(event_type, date, location)
    query_obj = all
    if date.blank?
      query_obj = query_obj.where("date >= ?", Date.today)
    else
      query_obj = query_obj.where("date >= ?", date) unless date.blank?
    end
    query_obj = query_obj.where("event_type_id = ?", event_type) unless event_type.blank?
    query_obj = query_obj.near(location, 20, :units => :km) unless location.blank?

    query_obj.order("date")
  end
end
