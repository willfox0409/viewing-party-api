require 'rails_helper'

RSpec.describe "ViewingParties API", type: :request do
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
end
