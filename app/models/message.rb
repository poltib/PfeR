class Message < ActiveRecord::Base
  has_many :conversations
  has_many :users, :through => :conversations
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
end
