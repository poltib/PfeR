class Team < ActiveRecord::Base
  has_many :teamers
  has_many :users, :through => :teamers
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
end
