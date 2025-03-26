class Api::V1::MoviesController < ApplicationController

  def index
    movies = MovieService.get_top_rated
    render json: MovieSerializer.new(movies)
  end
end 