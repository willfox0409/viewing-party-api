require 'rails_helper'

RSpec.describe MovieDetails do
  describe '.build_movie_details' do
    before do
      stub_request(:get, "https://api.themoviedb.org/3/movie/278")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          id: 278,
          title: "The Shawshank Redemption",
          release_date: "1994-09-23",
          vote_average: 8.7,
          runtime: 142,
          genres: [
            { id: 18, name: "Drama" },
            { id: 80, name: "Crime" }
          ],
          overview: "Imprisoned in the 1940s for the double murder..."
        }.to_json)

      stub_request(:get, "https://api.themoviedb.org/3/movie/278/credits")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          cast: [
            { character: "Andy Dufresne", name: "Tim Robbins" },
            { character: "Red", name: "Morgan Freeman" }
          ]
        }.to_json)

      stub_request(:get, "https://api.themoviedb.org/3/movie/278/reviews")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          results: [
            { author: "elshaarawy", content: "Great movie!" },
            { author: "John Chard", content: "Some birds aren't meant to be caged." }
          ]
        }.to_json)
    end

    it 'returns a MovieDetails object with formatted data' do
      movie = MovieDetails.build_movie_details(278)

      expect(movie).to be_a(MovieDetails)
      expect(movie.id).to eq(278)
      expect(movie.title).to eq("The Shawshank Redemption")
      expect(movie.release_year).to eq("1994")
      expect(movie.vote_average).to eq(8.7)
      expect(movie.runtime).to eq("2 hours, 22 minutes")
      expect(movie.genres).to eq(["Drama", "Crime"])
      expect(movie.summary).to be_a(String)
      expect(movie.cast.length).to be <= 10
      expect(movie.total_reviews).to eq(2)
      expect(movie.reviews.length).to eq(2)
      expect(movie.reviews.first).to have_key(:author)
      expect(movie.reviews.first).to have_key(:review)
    end
  end
end
