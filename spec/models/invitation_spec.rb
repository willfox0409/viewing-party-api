require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe ".add_user_to_party" do
    let(:user) { create(:user) }
    let(:party) do
      build(:viewing_party, movie_id: 278).tap do |vp|
        vp.save(validate: false)
      end
    end

    before do
      stub_request(:get, "https://api.themoviedb.org/3/movie/278")
        .with(query: hash_including({}))
        .to_return(
          status: 200,
          body: {
            id: 278,
            title: "The Shawshank Redemption",
            runtime: 120
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "creates an invitation when both user and party are valid" do
      result = Invitation.add_user_to_party(party.id, user.id)
      expect(result).to eq(party)
      expect(Invitation.last.user).to eq(user)
      expect(Invitation.last.viewing_party).to eq(party)
    end

    it "raises an error if the user is invalid" do
      expect {
        Invitation.add_user_to_party(party.id, 9999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
