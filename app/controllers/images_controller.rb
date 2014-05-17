class ImagesController < ApplicationController
  before_action :set_image, only: [:destroy]

  def index
  	@imagable = find_imagable
    @images = @imagable.images
  end

  def create
  	@imagable = image_params[:imagable_type].constantize.find image_params[:imagable_id]
    @image = @imagable.images.build(image_params)
    if @image.save
      # @image.create_activity :create, owner: current_user
      flash[:notice] = 'Image ajoutée.'
      redirect_to @imagable
    else
      render :action => :new
    end
  end

  def destroy
    @image.destroy
    redirect_to :back, :notice => 'Image supprimée.'
  end

  private
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:user_id, :imagable_id, :imagable_type, :image)
    end

    def find_imagable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
      nil
    end
end