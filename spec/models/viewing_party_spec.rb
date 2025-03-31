require 'rails_helper'

RSpec.describe ViewingParty, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:movie_title) }
    it { should validate_presence_of(:movie_id) }
  end

  describe "relationships" do
    it { should have_many(:invitations) }
    it { should have_many(:users).through(:invitations) }
  end

  describe "custom validations" do
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

    it "is invalid if end_time is before start_time" do
      party = build(:viewing_party, start_time: Time.now + 2.hours, end_time: Time.now + 1.hour)
      party.valid?

      expect(party.errors[:end_time]).to include("must be after start time")
    end

    it "is invalid if duration is shorter than movie runtime" do
      party = build(:viewing_party, start_time: Time.now, end_time: Time.now + 1.hour)
      party.valid?

      expect(party.errors[:base]).to include("Party duration must be at least the length of the movie")
    end

    it "is valid with a proper duration and time sequence" do
      party = build(:viewing_party, start_time: Time.now, end_time: Time.now + 3.hours)

      expect(party).to be_valid
    end
  end
end
