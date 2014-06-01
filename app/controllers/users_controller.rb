class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_action :set_user, only: [:show]

  def index
    @users = User.paginate(:page => params[:page], :per_page => 5)
  end

  def show
    @happenings = @user.happenings.order('date desc')
    @activities = PublicActivity::Activity.order('created_at desc').where(owner_id: params[:id], owner_type: 'User')
  end

  def dashboard
    @user = current_user
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    happenings = @user.user_statuses
    @events_by_date = happenings.group_by{ |happening| happening.happening.date.to_date }
    @happenings = Happening.all
  end

  private
    def set_user
      @user = User.find_by_username(params[:id])
    end
end
