class Status < ActiveRecord::Base
  has_many :user_statuses
end
