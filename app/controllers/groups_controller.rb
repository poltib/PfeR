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
    @user = User.find(current_user.id)
  	@group = Group.new(group_params)
  	@group.user_id = current_user.id
    if @group.save
      @group.users << @user
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
    group = params[:group].dup
    if group[:user_id]
      @user = User.find group[:user_id]
      if @group.users.include?(@user)
        @group.users.delete(@user)
        redirect_to group_path(@group), :notice => @user.username << ' ne fait plus partie du groupe'
      else  
        @group.users << @user
        redirect_to user_path(@user), :notice => @user.username << '  à bien été ajouté au groupe!'
      end
    else
      if @group.update_attributes group_params
          redirect_to groups_path, :notice => 'Your group has been successfully updated!'
      else
          render 'edit'
      end
    end
  end

  def destroy
    Group.destroy params[:id]
    redirect_to :back, :notice => 'Your group has been successfully deleted!'
  end

  private
    def group_params
      params.require(:group).permit(:name, :description, :avatar, :user_id)
    end
end
