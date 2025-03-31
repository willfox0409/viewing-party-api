class ViewingPartySerializer
  include JSONAPI::Serializer

  attributes :name, :start_time, :end_time, :movie_id, :movie_title 

  has_many :users
end