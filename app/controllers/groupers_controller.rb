class GroupersController < ApplicationController
  before_action :authenticate_user!
  before_filter :load_group
  before_filter :load_grouper, only: [:destroy, :update]

  def index
    @groupers = Grouper.all.where('group_id =?', @group.id)
  end

  def create
    @grouper = @group.groupers.build(grouper_params)
    @grouper.user = current_user
    if @grouper.save
      redirect_to group_path(@group), :notice => 'Votre demande d\'adhésion à bien été envoyée'
    else
      render 'new'
    end
  end

  def update
    @grouper.accepted_on = Time.now
    if @grouper.save
      redirect_to group_path(@group), :notice => 'L\'utilisateur fait partie du groupe'
    else
      render 'edit'
    end
  end

  def destroy
    @grouper.destroy
    redirect_to :back, :notice => 'L\'utilisateur ne fait plus partie du groupe.'
  end

  private
    def load_group
      @group = Group.find(params[:group_id])
    end

    def load_grouper
      @grouper = Grouper.find(params[:id])
    end

    def grouper_params
      params.permit(:user_id, :group_id, :grouper_id)
    end
end