class Api::V1::MoviesController < ApplicationController

  def index
    if params[:query].present?
      movies = MovieService.search_movies(params[:query])
    else
      movies = MovieService.get_top_rated_movies
    end

    render json: MovieSerializer.new(movies)
  end
end 