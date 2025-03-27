require 'rails_helper'

RSpec.describe "Movies endpoints", type: :request do
  describe "#index" do
    it "lists the top rated movies in TMDB" do

      get "/api/v1/movies/top_rated"

      movies = JSON.parse(response.body, symbolize_names: true)

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

      response = MovieService.get_top_rated_movies

      expect(response).to be_an(Array)
      expect(response.first.title).to eq("Pulp Fiction")
      expect(response.first.vote_average).to eq(9.2)

      # movies[:data].each do |movie|
      #   expect(response).to be_successful
      #   expect(merchants[:data].length).to eq(2)
      #   expect(merchant).to have_key(:id)
      #   expect(merchant[:id]).to be_an(String)
      #   expect(merchant[:attributes]).to have_key(:title)
      #   expect(merchant[:attributes]).to have_key(:vote_average)
      #   expect(merchant[:attributes][:name]).to be_a(String)
      #   expect(merchant[:attributes][:vote_average]).to be_a(String)
      end
    end
  end
end 