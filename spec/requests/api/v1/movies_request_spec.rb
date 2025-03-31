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
        expect(movie).to have_key(:id)
        expect(movie[:id]).to be_a(String)
      
        expect(movie).to have_key(:attributes)
        expect(movie[:attributes]).to have_key(:title)
        expect(movie[:attributes]).to have_key(:vote_average)
      
        expect(movie[:attributes][:title]).to be_a(String)
        expect(movie[:attributes][:vote_average]).to be_a(Float).or be_a(Integer)
      end
    end

    it "fetches movies based on search params" do

      stub_request(:get, "https://api.themoviedb.org/3/search/movie")
      .with(query: hash_including({ "page" => "1" }))
      .to_return(
        status: 200,
        body: {
          results: [
            { title: "The Lord of the Rings: The Fellowship of the Ring", vote_average: 8.413, id: 120 },
            { title: "The Lord of the Rings: The Return of the King", vote_average: 8.698, id: 122 },
            { title: "The Lord of the Rings: The Two Towers", vote_average: 8.397, id: 240 }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
      get "/api/v1/movies?query=Lord of The Rings"

      movies = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(movies[:data].length).to eq(3)

      movies[:data].each do |movie|
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

  describe "GET /api/v1/movies/:id" do
    it "returns detailed info for a specific movie" do
      movie_id = 278
  
      stub_request(:get, "https://api.themoviedb.org/3/movie/#{movie_id}")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          id: 278,
          title: "The Shawshank Redemption",
          release_date: "1994-09-23",
          vote_average: 8.7,
          runtime: 142,
          genres: [{ name: "Drama" }, { name: "Crime" }],
          overview: "Summary of the movie"
        }.to_json, headers: { "Content-Type" => "application/json" })
  
      stub_request(:get, "https://api.themoviedb.org/3/movie/#{movie_id}/credits")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          cast: [
            { character: "Andy Dufresne", name: "Tim Robbins" },
            { character: "Red", name: "Morgan Freeman" }
          ]
        }.to_json, headers: { "Content-Type" => "application/json" })
  
      stub_request(:get, "https://api.themoviedb.org/3/movie/#{movie_id}/reviews")
        .with(query: hash_including({}))
        .to_return(status: 200, body: {
          results: [
            { author: "elshaarawy", content: "A classic." },
            { author: "john_doe", content: "Loved it!" }
          ]
        }.to_json, headers: { "Content-Type" => "application/json" })
  
      get "/api/v1/movies/#{movie_id}"
  
      expect(response).to be_successful
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(json[:data][:id]).to eq(movie_id.to_s)
      expect(json[:data][:attributes][:title]).to eq("The Shawshank Redemption")
      expect(json[:data][:attributes][:release_year]).to eq("1994")
      expect(json[:data][:attributes][:runtime]).to eq("2 hours, 22 minutes")
      expect(json[:data][:attributes][:genres]).to include("Drama", "Crime")
      expect(json[:data][:attributes][:summary]).to be_a(String)
      expect(json[:data][:attributes][:cast].first).to include(:character, :actor)
      expect(json[:data][:attributes][:total_reviews]).to eq(2)
      expect(json[:data][:attributes][:reviews].first).to include(:author, :review)
    end

    it "returns 404 if the movie is not found" do
      invalid_id = 9999999
  
      stub_request(:get, "https://api.themoviedb.org/3/movie/#{invalid_id}")
        .with(query: hash_including({}))
        .to_return(status: 404, body: {
          status_message: "The resource you requested could not be found."
        }.to_json, headers: { "Content-Type" => "application/json" })

      stub_request(:get, "https://api.themoviedb.org/3/movie/#{invalid_id}/credits")
        .with(query: hash_including({}))
        .to_return(status: 404, body: {
          status_message: "The resource you requested could not be found."
        }.to_json, headers: { "Content-Type" => "application/json" })
      
      stub_request(:get, "https://api.themoviedb.org/3/movie/#{invalid_id}/reviews")
        .with(query: hash_including({}))
        .to_return(status: 404, body: {
          status_message: "The resource you requested could not be found."
        }.to_json, headers: { "Content-Type" => "application/json" })
  
      get "/api/v1/movies/#{invalid_id}"
  
      expect(response).to have_http_status(:not_found)
  
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors].first[:detail]).to match(/not found/i)
    end
  end
end 