class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)    # Not the final implementation!
    if @user.save
      render 'static_pages/howto'
    else
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:first, :last, :email, :password)
    end

end
