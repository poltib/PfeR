class WelcomeController < ApplicationController
  def index
  	@happenings = Happening.last(5)
  	@tracks = Track.last(5)
  	@user = User.new
  end
end
