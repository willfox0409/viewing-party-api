require 'rails_helper'

RSpec.describe Movie do 
  describe '#initialize' do 
    it 'exists and has attributes' do 
      movie_1 = Movie.new({ title: "Pulp Fiction", vote_average: 9.2, id: 238 })

      expect(movie_1).to be_an_instance_of(Movie)
      expect(movie_1.title).to eq("Pulp Fiction")
      expect(movie_1.vote_average).to eq(9.2)
      expect(movie_1.id).to eq(238)
    end
  end
end