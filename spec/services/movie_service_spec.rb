require 'rails_helper'

RSpec.describe MovieService do 
  describe 'INDEX / .get_top_rated_movies' do 
    it 'returns parsed movie data from TMDB API' do 
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
    end
  end

  describe 'INDEX / .search_movies' do 
    it 'returns parsed movie data from TMDB API based on search params' do 
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

      response = MovieService.search_movies("Lord of The Rings")

      expect(response).to be_an(Array)
      expect(response.length).to eq(3)
      expect(response.first.title).to eq("The Lord of the Rings: The Fellowship of the Ring")
      expect(response.first.vote_average).to eq(8.413)
    end
  end
end