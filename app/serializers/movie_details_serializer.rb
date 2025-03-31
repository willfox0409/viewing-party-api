class MovieDetailsSerializer
  include JSONAPI::Serializer
  set_type :movie

  attributes :title, :release_year, :vote_average, :runtime,
  :genres, :summary, :cast, :total_reviews, :reviews
end