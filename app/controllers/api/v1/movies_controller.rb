class Api::V1::MoviesController < ApplicationController

  def index
    movies = MovieService.get_top_rated_movies
    # puts MovieSerializer.new(movies).serializable_hash.to_json
    render json: MovieSerializer.new(movies)
  end
end 