class WelcomeController < ApplicationController
  def index
  	@happenings = Happening.search(params[:event_type], params[:date], params[:location])
  	@user = User.new
  end
end
