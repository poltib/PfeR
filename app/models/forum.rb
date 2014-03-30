class Forum < ActiveRecord::Base
	include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
	
	validates :title, :post, presence: true

	has_and_belongs_to_many :category

	belongs_to :user

	has_many :comments, dependent: :destroy
end
