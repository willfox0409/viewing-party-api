class MovieService

  def self.conn 
    Faraday.new(url: "https://api.themoviedb.org/3") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.movie_db_api_key
      faraday.params["language"] = "en-US"
    end
  end

  def self.get_top_rated_movies
    response = conn.get("movie/top_rated") do |req|
      req.params["page"] = 1
    end

    json = JSON.parse(response.body, symbolize_names: true)

    json[:results].map do |movie_data|
      Movie.new(movie_data)
    end
  end

  def self.search_movies(query)
    response = conn.get("search/movie") do |req|
      req.params["page"] = 1
      req.params["query"] = query
    end

    json = JSON.parse(response.body, symbolize_names: true)

    json[:results].map do |movie_data|
      Movie.new(movie_data)
    end
  end
end