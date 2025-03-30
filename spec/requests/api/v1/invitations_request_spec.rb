require 'rails_helper'

RSpec.describe "Invitations API", type: :request do
  describe "POST /api/v1/viewing_parties/:id/invitations" do
    it "successfully invites a new user to an existing viewing party" do 

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

      party = create(:viewing_party)
      existing_users = create_list(:user, 2) 
      party.users << existing_users #pre-load party with 2 users

      new_user = create(:user) #new invitee

      post "/api/v1/viewing_parties/#{party.id}/invitations",
        params: {invitees_user_id: new_user.id}.to_json, #add new_user as invitee in request body
        headers: { "CONTENT_TYPE" => "application/json" }
      
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body, symbolize_names: true)
      invited_ids = json[:data][:relationships][:users][:data].map { |user| user[:id].to_i } #convert json string to integer

      expect(Invitation.count).to eq(3)
      expect(invited_ids).to include(new_user.id)
    end
  end

  describe "POST Sad Paths" do 
    it "raises an error with an invalid viewing_party_id" do 
      invalid_party_id = 9999
      user = create(:user)
  
      post "/api/v1/viewing_parties/#{invalid_party_id}/invitations",
        params: { invitees_user_id: user.id }.to_json,
        headers: { "CONTENT_TYPE" => "application/json" }
  
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(:not_found)
      expect(json[:status]).to eq(404)
      expect(json[:message]).to match(/Couldn't find ViewingParty/)
      expect(Invitation.count).to eq(0)
    end

    it "raises an error with an invalid user_id" do
      party = build(:viewing_party)
      party.save(validate: false)
    
      invalid_user_id = 9999 #not in the database
    
      post "/api/v1/viewing_parties/#{party.id}/invitations",
        params: { invitees_user_id: invalid_user_id }.to_json,
        headers: { "CONTENT_TYPE" => "application/json" }
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:not_found)
      expect(json[:status]).to eq(404)
      expect(json[:message]).to match(/Invalid user/i)
      expect(Invitation.count).to eq(0)
    end
  end
end 