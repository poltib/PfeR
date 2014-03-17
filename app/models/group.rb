class Group < ActiveRecord::Base
  has_many :groupers
  has_many :users, :through => :groupers
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
end
