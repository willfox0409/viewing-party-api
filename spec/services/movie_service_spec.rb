require 'rails_helper'

RSpec.describe MovieService do 
  describe '.get_top_rated_movies' do 
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
end