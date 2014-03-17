class UserStatus < ActiveRecord::Base
  belongs_to :happening
  belongs_to :user
  belongs_to :status
end
