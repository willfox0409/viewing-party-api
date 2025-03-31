class ViewingParty < ApplicationRecord 
  has_many :invitations
  has_many :users, through: :invitations 

  validates :name, presence: true
  validates :movie_title, presence: true
  validates :movie_id, presence: true 

  validate :end_time_after_start_time
  validate :duration_meets_runtime

  def self.create_with_invitees(params)
    invitees = params.delete(:invitees) #delete AND EXTRACT
    party = ViewingParty.new(params) #initialize viewing party with params data (ruby object)
    runtime = MovieService.get_movie_runtime(params[:movie_id]) #makes real API call
    duration = ((party.end_time - party.start_time) / 60).to_i
  
    return party unless party.save #try to save party, if save fails, return early
    
    invitees.each_with_index do |user_id, index| # Loop through User IDs
      user = User.find_by(id: user_id)
      next unless user # skips invlaid users without raising an error

      Invitation.create!(
        user: user,
        viewing_party: party,
        host: index == 0 #know which one is first because of index block variable 
      )
    end #invitation belongs to party, Rails is just grabbing the foreign key party.id

    party
  end

  def end_time_after_start_time
    if end_time.present? && start_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def duration_meets_runtime
    return if movie_id.blank? || start_time.blank? || end_time.blank?

    runtime = MovieService.get_movie_runtime(movie_id)
    duration = ((end_time - start_time) / 60).to_i

    if duration < runtime
      errors.add(:base, "Party duration must be at least the length of the movie")
    end
  end
end