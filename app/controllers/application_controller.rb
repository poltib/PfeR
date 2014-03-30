class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include PublicActivity::StoreController
  
  protect_from_forgery with: :exception

  # def current_user
  #   @current_user ||= User.find(current_user.id) if session[:user_id]
  # end

end
