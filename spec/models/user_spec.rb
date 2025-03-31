require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:password) }
    it { should have_secure_password }
    it { should have_secure_token(:api_key) }
  end

  describe '#hosted_parties and #invited_parties' do
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

    it 'returns only hosted parties for the user' do
      user = create(:user)
      party1 = ViewingParty.create!(name: "Matrix Night", movie_id: 603, movie_title: "The Matrix", start_time: 1.day.from_now, end_time: 1.day.from_now + 3.hours)
      party2 = ViewingParty.create!(name: "Matrix Night 2", movie_id: 603, movie_title: "The Matrix", start_time: 2.days.from_now, end_time: 2.days.from_now + 3.hours)

      Invitation.create!(user: user, viewing_party: party1, host: true)
      Invitation.create!(user: user, viewing_party: party2, host: false)

      expect(user.hosted_parties).to contain_exactly(party1)
    end

    it 'returns only invited (non-host) parties for the user' do
      user = create(:user)
      party1 = ViewingParty.create!(name: "Matrix Night", movie_id: 603, movie_title: "The Matrix", start_time: 1.day.from_now, end_time: 1.day.from_now + 3.hours)
      party2 = ViewingParty.create!(name: "Matrix Night 2", movie_id: 603, movie_title: "The Matrix", start_time: 2.days.from_now, end_time: 2.days.from_now + 3.hours)

      Invitation.create!(user: user, viewing_party: party1, host: true)
      Invitation.create!(user: user, viewing_party: party2, host: false)

      expect(user.invited_parties).to contain_exactly(party2)
    end
  end
end