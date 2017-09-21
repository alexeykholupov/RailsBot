class UsersController < ApplicationController
  def index
    @user = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    @user.save
    redirect_to @user
  end

  def destroy
  @user = User.find(params[:id])
  @user.destroy
 
  redirect_to root_url
  end

  private
  def user_params
    params.require(:user).permit(:email, :password)
  end
end
