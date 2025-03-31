class Invitation < ApplicationRecord 
  belongs_to :user
  belongs_to :viewing_party

  def self.add_user_to_party(viewing_party_id, user_id)
    viewing_party = ViewingParty.find(viewing_party_id)
    user = User.find_by(id: user_id)
    raise ActiveRecord::RecordNotFound, "Invalid user" unless user 

    create!(
      user: user,
      viewing_party: viewing_party,
      host: false
    )

    viewing_party
  end
end 