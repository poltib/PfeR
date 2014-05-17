class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    happenings = @user.user_statuses
    @events_by_date = happenings.group_by{ |happening| happening.happening.date.to_date }
    @activities = PublicActivity::Activity.order('created_at desc').where(owner_id: params[:id], owner_type: 'User')
  end

  def dashboard
    @user = current_user
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    happenings = @user.user_statuses
    @events_by_date = happenings.group_by{ |happening| happening.happening.date.to_date }
  end
end
