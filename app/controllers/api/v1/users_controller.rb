class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: UserSerializer.new(user), status: :created
    else
      render json: ErrorSerializer.format_error(user.errors), status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end
end