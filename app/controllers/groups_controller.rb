class GroupsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  def index
    @groups = Group.all
  end

  def new
  	@group = Group.new
  end

  def show
  	@group = Group.find params[:id]
    @groupers = Grouper.all.where('group_id =?', params[:id])
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
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
      redirect_to groups_path, :notice => 'Votre groupe à été ajouté avec succès.'
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
        redirect_to groups_path, :notice => 'Votre groupe à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    Group.destroy params[:id]
    redirect_to :back, :notice => 'Votre groupe à été supprimé avec succès.'
  end

  private
    def group_params
      params.require(:group).permit(:name, :description, :avatar, :user_id)
    end
end
