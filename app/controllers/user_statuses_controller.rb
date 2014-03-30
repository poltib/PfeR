class UserStatusesController < ApplicationController
  before_filter :load_happening
  def index
  	@user_statuses = @happening.user_statuses
  end

  def create
  	@user_status = @happening.user_statuses.build(params[:user_status])
    @user_status.user = current_user
    if @user_status.save
      # @user_status.create_activity :create, owner: current_user
      redirect_to @happening, notice: "Vous participez à la course."
    else
      render :new
    end
  end

private

  def load_happening
    @happening = Happening.find(params[:happening_id])
  end
end