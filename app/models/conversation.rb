class Conversation < ActiveRecord::Base
  belongs_to :message
  belongs_to :user
end
