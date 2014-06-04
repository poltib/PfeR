class GroupsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_action :set_group, only: [:show, :destroy]

  def index
    if params[:user_id]
      @user = User.find_by_username params[:user_id]
      @groups = @user.groups_as_owner.paginate(:page => params[:page], :per_page => 10)
    else
      @groups = Group.all.paginate(:page => params[:page], :per_page => 10)
    end
  end

  def new
  	@group = Group.new
  end

  def show
    @groupers = Grouper.all.where('group_id =?', params[:id])
    @members = Grouper.all.where('group_id =?', params[:id]).where('accepted_on  IS NOT NULL')
    @waiting_users = Grouper.all.where('group_id =?', params[:id]).where('accepted_on  IS NULL')
    @happenings = @group.happenings.order('date desc')
  end

  def create
    @user = User.find(current_user.id)
  	@group = Group.new(group_params)
  	@group.user_id = current_user.id
    if @group.save
      grouper = @group.groupers.new
      grouper.user_id = @user.id
      grouper.accepted_on = Time.now
      grouper.save
      redirect_to group_path(@group), :notice => 'Votre groupe à été ajouté avec succès.'
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find params[:id]
  end

  def update
    @group = Group.find params[:id]
    group = params[:group].dup
    if @group.update_attributes group_params
        redirect_to group_path(@group), :notice => 'Votre groupe à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to :back, :notice => 'Votre groupe à été supprimé avec succès.'
  end

  private
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :description, :avatar, :user_id)
    end
end
