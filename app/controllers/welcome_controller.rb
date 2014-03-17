class WelcomeController < ApplicationController
  def index
  	@happenings = Happening.all
  end
end
