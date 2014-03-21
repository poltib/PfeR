class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def new
  	@group = Group.new
  end

  def show
  	@group = Group.find params[:id]
  end

  def create
  	@group = Group.new(group_params)
  	@group.user_id = current_user.id
    if @group.save
      redirect_to groups_path, :notice => 'Your group has been successfully created!'
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find params[:id]
  end

  def update
    @group = Group.find params[:id]

    if @group.update_attributes group_params
        redirect_to groups_path, :notice => 'Your group has been successfully updated!'
    else
        render 'edit'
    end
  end

  def addusers

  end

  def destroy
    Group.destroy params[:id]
    redirect_to :back, :notice => 'Your group has been successfully deleted!'
  end

  private
    def group_params
      params.require(:group).permit(:name, :description, :avatar)
    end
end
