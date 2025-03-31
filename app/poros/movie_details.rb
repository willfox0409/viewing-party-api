class MovieDetails 
  attr_reader :id, :title, :release_year, :vote_average, :runtime,
              :genres, :summary, :cast, :total_reviews, :reviews

  def initialize(details, credits, reviews)
    @id = details[:id]
    @title = details[:title]
    @release_year = details[:release_date][0..3] #extract just the year
    @vote_average = details[:vote_average]
    @runtime = format_runtime(details[:runtime])
    @genres = details[:genres].map { |genre| genre[:name] }
    @summary = details[:overview]
    @cast = format_cast(credits[:cast]) 
    @total_reviews = reviews[:results].count
    @reviews = format_reviews(reviews[:results])
  end

  def self.build_movie_details(movie_id)
    details = MovieService.get_movie_details(movie_id)
    credits = MovieService.get_movie_credits(movie_id)
    reviews = MovieService.get_movie_reviews(movie_id)

    if details.blank? || details[:id].nil? #Still shaky on this line of code
      raise ActiveRecord::RecordNotFound, "Movie not found"
    end
  
    MovieDetails.new(details, credits, reviews)
  end

  private

  def format_runtime(minutes)
    return "N/A" unless minutes
    hours = minutes / 60
    mins = minutes % 60
    "#{hours} hours, #{mins} minutes"
  end

  def format_cast(cast_array)
    cast_array.first(10).map do |member|
      {
        character: member[:character],
        actor: member[:name]
      }
    end
  end
  
  def format_reviews(review_array)
    review_array.first(5).map do |review|
      {
        author: review[:author],
        review: review[:content]
      }
    end
  end
end