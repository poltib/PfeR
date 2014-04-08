class HappeningsuserController < ApplicationController
	before_action :authenticate_user!
	def new
		@happening = Happening.find params[:happening_id]
	end

	def create
		@happening = Happening.find params[:happening_id]
		users = params[:happening].dup
		render text: users.inspect
		for user in users[:user_ids]

				@user = User.find user

		end
		# @user = User.where(["username = ?", user[:username]]).first
		# @user = User.find_by username: user[:username]

	end
end