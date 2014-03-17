class Happening < ActiveRecord::Base
  validates :name, :description, :address, :link, :date, presence: true

  has_many :user_statuses

  has_many :users, :through => :user_status

  belongs_to :owner, :class_name => "User", :foreign_key => :user_id

  belongs_to :event_type
end
