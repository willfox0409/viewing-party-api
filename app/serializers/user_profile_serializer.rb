class UserProfileSerializer
  include JSONAPI::Serializer
  set_type :user
  attributes :name, :username

  attribute :viewing_parties_hosted do |user|
    user.hosted_parties.map do |party|
      {
        id: party.id,
        name: party.name,
        start_time: party.start_time,
        end_time: party.end_time,
        movie_id: party.movie_id,
        movie_title: party.movie_title,
        host_id: user.id
      }
    end
  end

  attribute :viewing_parties_invited do |user|
    user.invited_parties.map do |party|
      {
        name: party.name,
        start_time: party.start_time,
        end_time: party.end_time,
        movie_id: party.movie_id,
        movie_title: party.movie_title,
        host_id: party.invitations.find_by(host: true)&.user_id
      }
    end
  end
end

  