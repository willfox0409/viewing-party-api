require 'rails_helper'

RSpec.describe "Movies endpoints", type: :request do
  describe "#index" do
    it "lists the top rated movies in TMDB" do

      stub_request(:get, "https://api.themoviedb.org/3/movie/top_rated")
      .with(query: hash_including({ "page" => "1" }))
      .to_return(
        status: 200,
        body: {
          results: [
            { title: "Pulp Fiction", vote_average: 9.2, id: 238 },
            { title: "Parasite", vote_average: 9.3, id: 278 }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
      get "/api/v1/movies"

      movies = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(movies[:data].length).to eq(2)

      movies[:data].each do |movie|
        puts JSON.pretty_generate(movies)
        expect(movie).to have_key(:id)
        expect(movie[:id]).to be_a(String)
      
        expect(movie).to have_key(:attributes)
        expect(movie[:attributes]).to have_key(:title)
        expect(movie[:attributes]).to have_key(:vote_average)
      
        expect(movie[:attributes][:title]).to be_a(String)
        expect(movie[:attributes][:vote_average]).to be_a(Float).or be_a(Integer)
      end
    end
  end
end 