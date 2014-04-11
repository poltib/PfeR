class Users::RegistrationsController < Devise::RegistrationsController
	  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(account_update_params)
    else
      # remove the virtual current_password attribute
      # update_without_password doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_without_password(account_update_params)
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
  def account_update_params
    params.require(:user).permit(:username, :lastname, :firstname, :description, :avatar, :email, :password, :password_confirmation, :current_password)
  end
  private :sign_up_params
  private :account_update_params
  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end
end