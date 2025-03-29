class ViewingParty < ApplicationRecord 
  has_many :invitations
  has_many :users, through: :invitations 

  validates :name, presence: true
  validates :movie_title, presence: true
  validates :movie_id, presence: true 

  def self.create_with_invitees(params)
    invitees = params.delete(:invitees) #delete AND EXTRACT
    party = ViewingParty.new(params) #initialize viewing party with params data (ruby object)

    return party unless party.save #try to save party, if save fails, return early

    invitees.each_with_index do |user_id, index| # Loop through User IDs
      user = User.find_by(id: user_id)
      raise ActiveRecord::RecordNotFound, "User ID #{user_id} not found" unless user

      Invitation.create!(
        user: user,
        viewing_party: party,
        host: index == 0 #know which one is first because of index block variable 
      )
    end #invitation belongs to party, Rails is just grabbing the foreign key party.id

    party
  end
  
end