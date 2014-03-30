class UsersController < ApplicationController
  def index
  	@users = User.all
  end

  def show
  	@user = User.find(params[:id])
  	@activities = PublicActivity::Activity.order("created_at desc").where(owner_id: params[:id], owner_type: "User")
  end
end
