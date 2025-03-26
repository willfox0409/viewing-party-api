class Api::V1::MoviesController < ApplicationController

  def index
    render json: MovieSerializer.format_user_list(Movie.all)
  end
end 