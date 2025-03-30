require 'rails_helper'

RSpec.describe "ViewingParties API", type: :request do
  before do
    stub_request(:get, "https://api.themoviedb.org/3/movie/278")
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        body: {
          id: 278,
          title: "The Shawshank Redemption",
          runtime: 142
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe "POST /api/v1/viewing_parties" do
    it "creates a viewing party with valid invitees" do 

      invitees = create_list(:user, 3)

      valid_params = {
        viewing_party: {
          name: "Juliet's Bday Movie Bash!",
          start_time: "2025-02-01 10:00:00",
          end_time: "2025-02-01 14:30:00",
          movie_id: 278,
          movie_title: "The Shawshank Redemption",
          invitees: invitees.map(&:id)
        }
      }

      post "/api/v1/viewing_parties", params: valid_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
      
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(ViewingParty.count).to eq(1)
      expect(Invitation.count).to eq(3)

      expect(json[:data]).to have_key(:id)
      expect(json[:data][:type]).to eq("viewing_party")
      expect(json[:data][:attributes][:name]).to eq("Juliet's Bday Movie Bash!")
      expect(json[:data][:relationships][:users][:data].count).to eq(3)
    end
  end

  describe "POST Sad Paths/Edge Cases" do 
    it "returns an error when required attributes are missing" do
      invitees = create_list(:user, 3)
    
      bad_params = {
        viewing_party: {
          #name is missing
          start_time: "2025-02-01 10:00:00",
          end_time: "2025-02-01 14:30:00",
          movie_id: nil,
          movie_title: "", #blank on purpose
          invitees: invitees.map(&:id)
        }
      }

      stub_request(:get, /api.themoviedb.org/).to_return( #regex matches any TMDB URL here
        status: 200,
        body: { runtime: 142 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    
      post "/api/v1/viewing_parties", params: bad_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:status]).to eq(422)
      messages = json[:errors].map { |e| e[:detail] }
      expect(messages).to include("Name can't be blank")
    end

    it "returns an error if runtime is less than party duration" do
      invitees = create_list(:user, 3)
    
      bad_params = {
        viewing_party: {
          name: "Juliet's Bday Movie Bash!",
          start_time: "2025-02-01 10:00:00",
          end_time: "2025-02-01 11:00:00", #duration is only an hour
          movie_id: 278,
          movie_title: "The Shawshank Redemption",
          invitees: invitees.map(&:id)
        }
      }
    
      post "/api/v1/viewing_parties", params: bad_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:status]).to eq(422)

      messages = json[:errors].map { |error| error[:detail] }
      expect(messages).to include("Party duration must be at least the length of the movie")
    end

    it "returns an error if end time is before start time" do
      invitees = create_list(:user, 3)
    
      bad_params = {
        viewing_party: {
          name: "Backwards Bash!",
          start_time: "2025-02-01 14:30:00",   #starts later
          end_time: "2025-02-01 10:00:00",     #ends earlier
          movie_id: 278,
          movie_title: "The Shawshank Redemption",
          invitees: invitees.map(&:id)
        }
      }
    
      stub_request(:get, "https://api.themoviedb.org/3/movie/278")
        .with(query: hash_including({}))
        .to_return(
          status: 200,
          body: {
            id: 278,
            title: "The Shawshank Redemption",
            runtime: 142
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    
      post "/api/v1/viewing_parties", params: bad_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:status]).to eq(422)

      messages = json[:errors].map { |e| e[:detail] }
      expect(messages).to include("End time must be after start time")
    end

    it "can create a viewing party with partially valid user id input" do
      valid_users = create_list(:user, 2)
      invalid_ids = [999, 1234] #these IDs don't exist
      invitees = valid_users.map(&:id) + invalid_ids
    
      params = {
        viewing_party: {
          name: "Juliet's Bday Movie Bash!",
          start_time: "2025-02-01 10:00:00",
          end_time: "2025-02-01 14:30:00",
          movie_id: 278,
          movie_title: "The Shawshank Redemption", 
          invitees: invitees
        }
      }
    
      post "/api/v1/viewing_parties", params: params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(ViewingParty.count).to eq(1)
      expect(Invitation.count).to eq(2)
      expect(response).to have_http_status(:created)
    end
  end
end

