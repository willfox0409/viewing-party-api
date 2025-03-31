require "rails_helper"

RSpec.describe "Users API", type: :request do
  describe "Create User Endpoint" do
    let(:user_params) do
      {
        name: "Me",
        username: "its_me",
        password: "QWERTY123",
        password_confirmation: "QWERTY123"
      }
    end

    context "request is valid" do
      it "returns 201 Created and provides expected fields" do
        post api_v1_users_path, params: user_params, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:type]).to eq("user")
        expect(json[:data][:id]).to eq(User.last.id.to_s)
        expect(json[:data][:attributes][:name]).to eq(user_params[:name])
        expect(json[:data][:attributes][:username]).to eq(user_params[:username])
        expect(json[:data][:attributes]).to have_key(:api_key)
        expect(json[:data][:attributes]).to_not have_key(:password)
        expect(json[:data][:attributes]).to_not have_key(:password_confirmation)
      end
    end

    context "request is invalid" do
      it "returns an error for non-unique username" do
        User.create!(name: "me", username: "its_me", password: "abc123")

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username has already been taken")
        expect(json[:status]).to eq(400)
      end

      it "returns an error when password does not match password confirmation" do
        user_params = {
          name: "me",
          username: "its_me",
          password: "QWERTY123",
          password_confirmation: "QWERT123"
        }

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Password confirmation doesn't match Password")
        expect(json[:status]).to eq(400)
      end

      it "returns an error for missing field" do
        user_params[:username] = ""

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username can't be blank")
        expect(json[:status]).to eq(400)
      end
    end
  end

  describe "#index - Get All Users Endpoint" do
    it "retrieves all users but does not share any sensitive data" do
      User.create!(name: "Tom", username: "myspace_creator", password: "test123")
      User.create!(name: "Oprah", username: "oprah", password: "abcqwerty")
      User.create!(name: "Beyonce", username: "sasha_fierce", password: "blueivy")

      get api_v1_users_path

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].count).to eq(3)
      expect(json[:data][0][:attributes]).to have_key(:name)
      expect(json[:data][0][:attributes]).to have_key(:username)
      expect(json[:data][0][:attributes]).to_not have_key(:password)
      expect(json[:data][0][:attributes]).to_not have_key(:password_digest)
      expect(json[:data][0][:attributes]).to_not have_key(:api_key)
    end
  end

  describe "#show - Get User Profile Endpoint" do
    before do 
      stub_request(:get, "https://api.themoviedb.org/3/movie/603")
        .with(query: hash_including({}))
        .to_return(
          status: 200,
          body: {
            id: 603,
            title: "The Matrix",
            runtime: 136
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end
    it "returns a user's full profile with hosted and invited parties" do #happy path
      user = User.create!(name: "Keanu", username: "neo", password: "matrix")
      party = ViewingParty.create!(
        name: "Matrix Reloaded",
        movie_id: 603,
        movie_title: "The Matrix Reloaded",
        start_time: Time.now + 1.day,
        end_time: Time.now + 1.day + 3.hours
      )
      Invitation.create!(user: user, viewing_party: party, host: true)

      get "/api/v1/users/#{user.id}" #I like to use explicit path 

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:id]).to eq(user.id.to_s)
      expect(json[:data][:type]).to eq("user")
      expect(json[:data][:attributes][:name]).to eq("Keanu")
      expect(json[:data][:attributes][:username]).to eq("neo")

      expect(json[:data][:attributes]).to have_key(:viewing_parties_hosted)
      expect(json[:data][:attributes]).to have_key(:viewing_parties_invited)
      expect(json[:data][:attributes]).to_not have_key(:password_digest)
      expect(json[:data][:attributes]).to_not have_key(:api_key)
    end

    it "returns 404 if the user is not found" do #sad path 
      get "/api/v1/users/999999"

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors].first[:detail]).to match(/couldn't find user/i) #regex matching case insensitive
    end
  end
end
