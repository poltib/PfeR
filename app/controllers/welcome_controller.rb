class WelcomeController < ApplicationController
  def index
  	@happenings = Happening.all
  	@user = User.new
  end
end
