class Forum < ActiveRecord::Base
	validates :title, :post, presence: true

	has_and_belongs_to_many :category

	belongs_to :user

	has_many :comments, dependent: :destroy
end
