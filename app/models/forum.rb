class Forum < ActiveRecord::Base
	include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
	
	validates :name, :post, presence: true

	has_and_belongs_to_many :categories

	belongs_to :user

	has_many :comments, dependent: :destroy
	
	has_many :favorites, :as => :favoritable, dependent: :destroy
end
