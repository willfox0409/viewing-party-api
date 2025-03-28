class MovieSerializer
  include JSONAPI::Serializer
  
  attributes :title, :vote_average
end