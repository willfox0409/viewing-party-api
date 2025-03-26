class MovieService
  def self.get_top_rated_movies
    response = Faraday.get("https://api.themoviedb.org/3/movie/top_rated") do |req|
      req.params["api_key"] = Rails.application.credentials.movie_db_api_key
      req.params["language"] = "en-US"
      req.params["page"] = 1
    end

    json = JSON.parse(response.body, symbolize_names: true)

    json[:results].map do |movie_data|
      Movie.new(movie_data)
    end
  end
end